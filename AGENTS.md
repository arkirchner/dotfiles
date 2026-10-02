# AGENTS: Repository Operating Guide

NixOS dotfiles for three machines, built as a flake with flake-parts and
`import-tree`. Follow the conventions below when editing.

## Layout

- `nix_config/flake.nix` — inputs and `mkFlake`.
- `nix_config/modules/flake/` — flake wiring: `systems.nix`, `home-manager.nix`,
  `dev-shells.nix`, `formatter.nix`.
- `nix_config/modules/nixos/` — NixOS modules. `core/` (os-wide),
  `desktop/`, `editors/`, `services/`, and `shared.nix` (the import list every
  host gets).
- `nix_config/modules/home/` — Home Manager modules. `armin.nix` is the user
  entry point, `home.nix` holds `home.packages`, `desktop/desktop-programs.nix`
  the desktop imports.
- `nix_config/modules/hosts/<machine>/` — one directory per host
  (`720s` = armin-laptop, `x600` = armin-pc, `dell_5450` = armin-work-laptop):
  `configuration.nix` (host options), `hardware.nix`,
  `home-manager.nix` (host-specific Home Manager config, e.g. niri outputs).
- `nix_config/packages/` — locally built packages.
- `nix_config/devenv/` — one directory per project that has services, each with
  a `devenv.nix` that an app repo reaches through `use devenv --from`. See
  "Project services" below.
- `nix_config/shells/` — dev shell bodies. They return a
  `{ buildInputs, shellEnv, shellHook }` definition rather than a shell, so that
  `rails-devenv.nix` can hand the same one to a devenv. `rails-base.nix` and
  `rails-mcp.nix` are shared pieces, not shells themselves.
- `nix_config/secrets/`, `nix_config/.sops.yaml` — sops-nix, PGP/YubiKey only.
- `nix_config/wallpapers/` — Noctalia wallpaper directory.

Every `.nix` file under `nix_config/modules` is imported as a module; files
whose path contains a `_` component (e.g. `_hardware-configuration.nix`) are
skipped. Modules define `flake.modules.<namespace>.<name>` and are wired
together by explicit references, not by directory structure.

## Build / verify commands

Always name the host.

```bash
# Evaluate all three configurations, no build. Catches duplicate attributes.
cd nix_config && nix flake check

# Build a system (does not switch).
sudo nixos-rebuild build --flake .#armin-pc          # also #armin-laptop, #armin-work-laptop
sudo nixos-rebuild switch --flake .#armin-pc

# The rendered niri config, validated with niri.
nix build .#nixosConfigurations.armin-pc.config.home-manager.users.armin.xdg.configFile."niri/config.kdl".source
niri validate -c "$(nix build --no-link --print-out-paths .#nixosConfigurations.armin-pc.config.home-manager.users.armin.xdg.configFile."niri/config.kdl".source)"

# Dev shells.
nix develop .#codeocean      # also #wave-walker, #agent-rails, #agent-xikolo
nix develop .#agent-dotfiles # nil, statix, deadnix, and the nix MCP

# Which MCP servers a shell turned on.
opencode mcp list

# Per-project services, in the app repos. See "Project services" below.
cd ~/Documents/xikolo && devenv-up      # postgres
cd ~/Documents/codeocean && devenv-up   # postgres + nomad
devenv-down                              # stop them

# Format (treefmt + nixfmt + deadnix, config in treefmt.toml).
nix fmt
nix fmt -- --fail-on-change  # what CI should run
```

There is no test runner and no CI workflow.

## Dev shells and MCP servers

`modules/home/opencode/default.nix` registers the `nixos`, `context7` and
`rails` MCP servers globally, so they are on in every project. A dev shell
narrows that down: it exports `OPENCODE_CONFIG` pointing at a JSON file it
generates into the store, and opencode merges that between the global and the
project config (`enabled: false` on a server is the override).

The two splits are:

| Shell | MCPs |
| --- | --- |
| `agent-dotfiles` | `context7`, `nixos` — `rails` disabled |
| `codeocean`, `agent-rails`, `agent-xikolo` | `context7`, `rails`, `playwright`, `serena` — `nixos` disabled |

A repo that only wants a shell opts in with an `.envrc`; it needs no opencode
config of its own:

```bash
use flake ../dotfiles/nix_config#agent-rails   # or #agent-xikolo, #codeocean
```

Use `use flake`, not `use nix <file>`. The shell bodies take a required `pkgs`
argument, which `nix-shell` will not supply, so `use nix` on them fails with
"cannot evaluate a function that has an argument without a value".

`shells/rails-base.nix` is the shared Ruby toolchain and `shells/rails-mcp.nix`
is the shared MCP set; neither is a shell itself. The per-app bodies import both
and pass `extraBuildInputs`, `extraLibPath`, `extraShellEnv` and
`extraShellHook`. `mkShell` does not derive `LD_LIBRARY_PATH`, so `rails-base`
assigns it from `nativeLibs ++ extraLibPath` — anything a native gem links
against has to be named in one of those two. `dev-shells.nix` wraps the result
in `mkShell`, taking only `buildInputs` and `shellHook`: passing the whole
attribute set would have stdenv try to coerce `shellEnv` into an env var.

## Project services

PostgreSQL is not a NixOS service any more. It belongs to the project that needs
it, as a devenv service, so it only exists while that project's environment is
up. `xikolo` has postgres; `codeocean` has postgres and nomad.

The definitions live here, in `nix_config/devenv/<app>/devenv.nix`. The app repo
holds **no devenv files**: its `.envrc` is a single `use devenv --from` line that
names the definition, and that is enough.

```bash
use devenv --from ../dotfiles/nix_config/devenv/xikolo \
  -o nixpkgs "github:NixOS/nixpkgs/$(nix flake metadata --json ../dotfiles/nix_config | jq -r .locks.nodes.nixpkgs.locked.rev)"
```

`--from` makes devenv read `devenv.nix` from an arbitrary directory while
`config.devenv.root` stays the app directory. So `.bundle`, `PGDATA` and
`$DEVENV_STATE` are per-app even though the definition is shared, and
`PGHOST` becomes a socket under `/run/user/$(id -u)/devenv-<hash of the root>`.
Two directories of the same app therefore run two independent clusters with the
same database names — `~/Documents/xikolo` and `~/Documents/xikolo2` need no
coordination, which is the point.

`-o nixpkgs` is what keeps one nixpkgs in the store. Without it devenv resolves
its own `cachix/devenv-nixpkgs:rolling`, because the `inputs.nixpkgs.follows` that
would tie it to this flake has nowhere to live once there is no `devenv.yaml`.
Reading the revision out of `flake.lock` costs ~60ms per load and needs `jq` on
the plain `PATH`, because direnv evaluates `.envrc` before any dev shell is
active.

`use devenv` itself comes from `programs.direnv.stdlib` in
`modules/home/fish/default.nix`, which `eval`s `devenv direnvrc` into
`~/.config/direnv/direnvrc`. It has to be `eval`, not
`source "$(devenv direnvrc)"`: that form fails under bash 5.3 with "File name too
long" instead of sourcing the string as a script.

The toolchain comes from here too. `nix_config/devenv/<app>/devenv.nix` imports
the app's shell body over relative paths and wraps it in
`shells/rails-devenv.nix`. That module takes `base`, `lib` and `root` explicitly,
because devenv calls imported modules with no implicit arguments. It resolves the
`$PWD` that the shellEnv relies on against `config.devenv.root` — devenv sets env
vars verbatim and cannot expand it — and leaves `PATH` alone, since only a shell
can expand its own `$PATH`.

Starting and stopping is explicit, through two fish functions from
`modules/home/fish/default.nix`. devenv's direnvrc exports `DEVENV_CMDLINE`, so
they replay whatever `--from` the current `.envrc` passed and work unchanged in
every app:

```bash
devenv-up      # devenv up -d $DEVENV_CMDLINE
devenv-down    # devenv down $DEVENV_CMDLINE
```

Two things to know when writing one:

- **Do not set `DATABASE_URL`.** `config/database.yml` reads it per environment,
  so a single URL overrides the distinct `database:` names and collapses e.g. the
  queue database into the primary one. `PGHOST`, which devenv points at the
  per-project socket, is enough.
- **Unfree packages** cannot be allowed from here at all. devenv reads
  `allow_unfree` from YAML in the *project* root only: a user config accepts just
  `shell`/`tui`/`version`, and no option in `devenv.nix` reaches it. So an app
  with an unfree package carries a `devenv.local.yaml` — codeocean's is two
  lines, because nomad is BSL. That is the only file an app repo needs beyond
  `.envrc`.

Adding a project is therefore: a `nix_config/devenv/<app>/devenv.nix`, an
`.envrc` in the app repo, and a `devenv.local.yaml` if anything in it is unfree.

devenv writes a `devenv.lock` and a `.devenv/` into the app root. Neither is
committed, and neither is gitignored — `devenv.lock` shows up as untracked, which
was the lesser evil against editing five repos' `.gitignore`. `$DEVENV_STATE` is
80M+ of postgres data per directory, so four parallel clones of one app is a few
hundred MB and one postgres process each.

## Style

- 2-space indentation, opening brace on the same line. Formatting is
  automated: run `nix fmt` rather than reformatting by hand.
- One item per line in non-trivial lists.
- `''` for multi-line strings, `"` for simple ones.
- Small `let` blocks for shared values; `let ... in` instead of repeating.
- No dead code, no commented-out code. If something is left on purpose, say why
  in a comment.
- Explicit `imports = [ ... ];`, one path per line.
- Prefer `lib.mkIf` / `lib.mkDefault` / `lib.mkForce` over duplicating config.
  `mkDefault` for values a host may override (e.g. `services.nomad.enable`).
- Use `pkgs` from the module arguments; never re-import nixpkgs.
- Keep host-specific values (hostnames, monitor layout, CPU governor) in
  `modules/hosts/<machine>/`, not in shared modules.
- Prefer `assert` / `lib.assertMsg` for non-obvious constraints.

## Git

- Commits are GPG signed; never disable signing.
- Default branch is `master`.
- Editor is `nvim`.
- Note: this repo is a git flake, so *untracked* files are invisible to `nix`.
  Stage a new file (`git add`) before evaluating the flake, or it will look
  like the file does not exist.

## Adding things

- New NixOS option → a file in `modules/nixos/<area>/`, added to
  `modules/nixos/shared.nix` if it should apply to every host, or imported from
  the host's `configuration.nix` if not.
- New Home Manager option → a file in `modules/home/<name>/`, added to
  `modules/home/armin.nix`, `home.nix` or `desktop/desktop-programs.nix`.
- New host → a directory in `modules/hosts/`, and a `default.nix` that calls
  `nixpkgs.lib.nixosSystem` with `flake.modules.nixos.shared` plus
  `flake.modules.nixos."nixosConfigurations/<name>"`.
