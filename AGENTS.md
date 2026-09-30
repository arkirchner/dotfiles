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
cd ~/Documents/xikolo && devenv up -d      # postgres
cd ~/Documents/codeocean && devenv up -d   # postgres + nomad
devenv processes down                      # stop them

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
up. `xikolo` has postgres; `codeocean` has postgres and nomad. Each app repo
carries its own `devenv.nix` and `devenv.yaml` and activates them with:

```bash
eval "$(devenv direnvrc)"
```

The toolchain still comes from here: `devenv.yaml` takes this flake as the
`dotfiles` input (with `nixpkgs.follows: dotfiles/nixpkgs`, so there is one
nixpkgs in the store), and `devenv.nix` imports the app's shell body and wraps
it in `shells/rails-devenv.nix`. That module takes `base`, `lib` and `root`
explicitly, because devenv calls imported modules with no implicit arguments.
It resolves the `$PWD` that the shellHook relies on against `config.devenv.root`
— devenv sets env vars verbatim and cannot expand it — and leaves `PATH` alone,
since only a shell can expand its own `$PATH`.

Two things to know when writing one:

- **Do not set `DATABASE_URL`.** `config/database.yml` reads it per environment,
  so a single URL overrides the distinct `database:` names and collapses e.g. the
  queue database into the primary one. `PGHOST`, which devenv points at the
  per-project socket, is enough.
- **Unfree packages** need a top-level `nixpkgs.per_platform.<system>` block in
  `devenv.yaml`, not `nixpkgs.config` in `devenv.nix` (devenv has no `nixpkgs`
  option). nomad is BSL, so codeocean lists it under
  `permitted_unfree_packages`.

`$DEVENV_STATE` is 80M+ of postgres data per project, so `.devenv*` is
gitignored in the app repos.

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
