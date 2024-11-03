{ config, lib, pkgs, ... }:
{
  services.postgresql = {
    enable = true;

    package = pkgs.postgresql_16;

    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';

    ensureDatabases = [
      "armin"
    ];

    ensureUsers = [
      {
        name = "armin";
        ensureDBOwnership = true;

        ensureClauses = {
            superuser = true;
            createrole = true;
            createdb = true;
        };
      }
    ];
  };
}
