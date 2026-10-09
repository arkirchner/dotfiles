# The xikolo dev environment, kept here rather than in the app repo. An app
# carries no devenv files at all: its .envrc is a single `use devenv --from`
# pointing at this directory, and that is enough. `devenv --from` reads
# devenv.nix from wherever it is told to, so the definition can live here.
#
# config.devenv.root is the *app* directory even though this file lives here, so
# .bundle, the postgres socket and $DEVENV_STATE all stay per-app. That is what
# lets ~/Documents/xikolo and ~/Documents/xikolo2 run side by side: same
# definition, same databases, no shared state and no socket collision.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Relative paths, so this resolves against this file's own location and does
  # not depend on how the app named this input.
  shells = ../../shells;
  base = import (shells + "/agent-xikolo.nix") { inherit pkgs; };

  # The identity seaweedfs authenticates against. One identity, and it needs
  # "Admin" as well as Read/Write: `rake local_s3:configure` creates the buckets
  # and calls PutBucketPolicy on five of them, which are Admin operations.
  # SeaweedFS does implement PutBucketPolicy, so the public-read policies the
  # task sets are honoured.
  #
  # These are development credentials for a store that only listens on
  # loopback, and they have to match the S3_ACCESS_ID/S3_ACCESS_KEY exported
  # below, so there is nothing to keep secret here.
  s3Identity = pkgs.writeText "s3-identity.json" (
    builtins.toJSON {
      identities = [
        {
          name = "xikolo";
          credentials = [
            {
              accessKey = "xikolo";
              secretKey = "xikolo";
            }
          ];
          actions = [
            "Admin"
            "Read"
            "Write"
            "List"
            "Tagging"
          ];
        }
      ];
    }
  );

  # Base ports for the four listeners `weed server` opens. These are only where
  # devenv starts searching: it takes the first free port at or above each, so
  # two clones of this app can be up at once and land on different ports. That
  # is the same property the postgres socket hash gives the databases, and the
  # reason S3_PROVIDER_ENDPOINT below is read from the allocated value instead
  # of hardcoded to 8333.
  s3BasePort = 8333;
  masterBasePort = 9333;
  volumeBasePort = 8080;
  filerBasePort = 8888;
in
{
  imports = [
    (import (shells + "/rails-devenv.nix") {
      inherit base lib;
      root = config.devenv.root;
    })
  ];

  # The app loads its own .env, through `gem "dotenv", groups: %i[development
  # test]` in the Gemfile, and app/controllers/maintenance_task_controller.rb does
  # an ENV.fetch with no default on one of those keys. Loading it here as well
  # would put the values into the devenv environment, where postgres and
  # everything else this project starts inherits them, and would freeze them at
  # evaluation time rather than re-reading them per boot. So the hint is silenced
  # instead of satisfied.
  dotenv.disableHint = true;

  # The database this app needs, and nothing else: no host-level postgres, no
  # cluster outside $DEVENV_STATE.
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;

    # The names in config/database.yml, not one named after the user.
    createDatabase = false;
    initialDatabases = [
      {
        name = "xikolo";
      }
      {
        name = "xikolo_queue";
      }
      {
        name = "xikolo-test";
      }
    ];
  };

  # DATABASE_URL is deliberately not set. database.yml reads it per environment
  # and a single URL would override the distinct `database:` names, collapsing
  # the queue database into the primary one. PGHOST, which devenv points at
  # this project's socket, is enough.

  # The object store, as a devenv process for the same reason postgres is: it
  # should only exist while this project is up.
  #
  # `weed server` runs master, volume, filer and the S3 gateway in a single
  # process, which is what a one-node development store wants.
  #
  # -volume.max is not optional. Every S3 bucket becomes its own *collection*,
  # and a collection needs a volume of its own to be writable. A bucket created
  # through the API has no collection behind it until something first writes to
  # it, so with the default of 8 volumes `rake local_s3:configure` reports
  # success and then the first write to the second bucket fails with "No
  # writable volumes and no free volumes left for collection:...", which
  # surfaces in Ruby as a bare InternalError with nothing pointing at the
  # cause. 64 leaves room for the six buckets this app uses plus their growth,
  # and -master.volumeSizeLimitMB keeps each volume small so that many of them
  # cost little disk.
  #
  # -s3.port.iceberg=0 turns off the Iceberg REST catalog, which this app has no
  # use for. It defaults to a fixed 8181 that no devenv port allocation covers,
  # and failing to bind it is fatal, so without this the second clone of the app
  # kills itself on startup and reports "gave_up" while the first keeps running.
  processes.seaweedfs = {
    exec = ''
      # weed server checks that its data directory is writable at startup and
      # aborts if it is missing, and devenv creates only the state directory
      # above it, not this one.
      mkdir -p ${config.devenv.state}/seaweedfs

      exec ${lib.getExe pkgs.seaweedfs} server \
        -dir=${config.devenv.state}/seaweedfs \
        -s3 \
        -s3.config=${s3Identity} \
        -master.port=${toString config.processes.seaweedfs.ports.master.value} \
        -volume.port=${toString config.processes.seaweedfs.ports.volume.value} \
        -filer.port=${toString config.processes.seaweedfs.ports.filer.value} \
        -s3.port=${toString config.processes.seaweedfs.ports.s3.value} \
        -s3.port.iceberg=0 \
        -volume.max=64 \
        -master.volumeSizeLimitMB=512
    '';

    ports.master.allocate = masterBasePort;
    ports.volume.allocate = volumeBasePort;
    ports.filer.allocate = filerBasePort;
    ports.s3.allocate = s3BasePort;

    # The gateway is up once it answers at all. ready.exec with a plain curl,
    # not ready.http.get: the S3 root returns 403 without credentials, and the
    # http probe treats any non-2xx as "still starting", so it would never
    # pass and the daemon would give up after its startup timeout. curl without
    # --fail exits 0 on a 403, which still proves the gateway is serving, and
    # non-zero on a refused connection, which is what we are waiting for.
    ready.exec = ''
      curl -s -o /dev/null --max-time 5 \
        http://127.0.0.1:${toString config.processes.seaweedfs.ports.s3.value}/
    '';

    restart.on = "always";
  };

  # What the app's S3 client is pointed at. Only these four variables matter:
  # gems/xikolo-s3/lib/xikolo/s3.rb builds its client from S3_ACCESS_ID,
  # S3_ACCESS_KEY, S3_PROVIDER_ENDPOINT and AWS_REGION, and sets
  # force_path_style: true whenever the endpoint is present.
  #
  # The `connect_info` block in xikolo.development.yml is not read by anything.
  # That file supplies the bucket *names*, which the app does use, but the
  # endpoint and credentials reach it only through the environment.
  #
  # dotenv loads the app's .env at boot and does not overwrite variables that are
  # already set, so exporting these here wins over the MinIO endpoint
  # (127.0.0.1:9000) and credentials that .env carries. The repo therefore keeps
  # its MinIO defaults for the docker-compose setup, while this environment talks
  # to seaweedfs, with nothing changed in the app.
  env = {
    S3_ACCESS_ID = "xikolo";
    S3_ACCESS_KEY = "xikolo";
    S3_PROVIDER_ENDPOINT = "http://127.0.0.1:${toString config.processes.seaweedfs.ports.s3.value}";
    AWS_REGION = "us-east-1";
  };
}
