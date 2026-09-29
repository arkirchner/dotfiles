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
- `nix_config/shells/` — dev shell bodies. `rails-base.nix` and `rails-mcp.nix`
  are shared pieces, not shells themselves.
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
nix develop .#codeocean      # also #wave-walker
nix develop .#agent-rails    # Rails toolchain + the Rails MCP set
nix develop .#agent-xikolo   # same MCP set, plus the xikolo build deps
nix develop .#agent-dotfiles # nil, statix, deadnix, and the nix MCP

# Which MCP servers a shell turned on.
opencode mcp list

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
| `agent-rails`, `agent-xikolo` | `context7`, `rails`, `playwright`, `serena` — `nixos` disabled |

An app repo opts in with an `.envrc`; it needs no opencode config of its own:

```bash
use flake ../dotfiles/nix_config#agent-rails   # or #agent-xikolo
```

Use `use flake`, not `use nix <file>`. The shell bodies take a required `pkgs`
argument, which `nix-shell` will not supply, so `use nix` on them fails with
"cannot evaluate a function that has an argument without a value".

`shells/rails-base.nix` is the shared Ruby toolchain and `shells/rails-mcp.nix`
is the shared MCP set; neither is a shell itself. The per-app shells import both
and pass `extraBuildInputs`, `extraLibPath` and `extraShellHook`. `mkShell` does
not derive `LD_LIBRARY_PATH`, so `rails-base` assigns it from
`nativeLibs ++ extraLibPath` — anything a native gem links against has to be
named in one of those two.

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
