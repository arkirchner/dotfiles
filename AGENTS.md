# AGENTS: Repository Operating Guide

This repository is a Nix-based dotfiles setup with multiple subtrees
(`nix_config/`, `nix-darwin/`, `servers/`, `shells/`, etc.).
Follow the conventions below when editing.

## Scope and Structure
- Primary NixOS configuration: `nix_config/flake.nix`.
- NixOS host configs: `nix_config/machines/*/configuration.nix`.
- Shared NixOS modules: `nix_config/nixos_modules/**`.
- Home Manager programs: `nix_config/programs/**`.
- Darwin system flake: `nix-darwin/flake.nix`.
- Dev shells: `nix_config/shells/**`.
- Server bootstrap: `servers/configuration.nix` + `servers/README.md`.

## Build / Lint / Test Commands
There is no centralized build/test tooling beyond Nix commands.
Prefer the commands below and be explicit about target hosts.

### NixOS
- Build a system (no switch):
  `nixos-rebuild build --flake /home/armin/Documents/dotfiles/nix_config#armin-pc`
- Switch to a system:
  `sudo nixos-rebuild switch --flake /home/armin/Documents/dotfiles/nix_config#armin-pc`
- Other host examples (from `nix_config/flake.nix`):
  `#armin-laptop`, `#armin-work-laptop`.

### Darwin
- Build darwin flake (see `nix-darwin/flake.nix`):
  `darwin-rebuild build --flake /home/armin/Documents/dotfiles/nix-darwin#PC0099`
- Switch darwin system:
  `darwin-rebuild switch --flake /home/armin/Documents/dotfiles/nix-darwin#PC0099`

### Dev Shells
- Enter a dev shell (example):
  `nix develop /home/armin/Documents/dotfiles/nix_config/shells/xikolo`
- Non-flake shell (example):
  `nix-shell /home/armin/Documents/dotfiles/nix_config/shells/codeocean.nix`
- These shells may run setup steps in `shellHook` (e.g., `yarn install`).

### Servers
- Bootstrap a server with nixos-infect (see `servers/README.md`):
  `curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | \
    NIX_CHANNEL=nixos-24.11 \
    NIXOS_CONFIG=https://raw.githubusercontent.com/arkirchner/dotfiles/refs/heads/master/servers/configuration.nix \
    bash -x`

### Lint / Format
- No formatter is explicitly configured.
- If you add a formatter, prefer `nix fmt` at repo root and document it.
- Do not auto-format unless requested or the repo already uses a formatter.

### Tests
- No project-wide test runner is defined.
- If you touch a subproject with its own tests, document and run those.

### Running a Single Test
- Not applicable at repo root.
- If you are in a subproject (e.g., within a dev shell), follow that
  project's local `README` or tooling for single-test commands.
- Neovim includes `vim-test`; prefer its project-specific runners when used.

## Code Style Guidelines

### Nix Formatting and Style
- Indentation: 2 spaces.
- Braces: place opening brace on same line, close aligned.
- Lists: one item per line for non-trivial lists; trailing commas are OK.
- Attributes: align nested blocks for readability, avoid extra blank lines.
- Strings: use double quotes for simple strings; use `''` for multi-line.
- Prefer `let ... in` for shared values; keep `let` blocks small.
- Keep commented-out code minimal; remove dead code unless a note is needed.
- Keep whitespace consistent; avoid trailing spaces.

### Imports and Module Layout
- Use explicit `imports = [ ... ];` with one path per line.
- Group imports logically (core modules, optional modules, local files).
- For Home Manager modules, keep program-specific config in
  `nix_config/programs/<name>/default.nix`.
- For shared NixOS logic, prefer `nix_config/nixos_modules/**`.
- Keep `hardware-configuration.nix` machine-specific only.

### Naming Conventions
- File and directory names: lowercase with underscores where already used.
- Nix attributes: lowerCamelCase for local names; follow existing pattern.
- Modules: prefer `default.nix` entry points for directories.
- Avoid renaming machine directories without updating `flake.nix`.

### Types and Options
- Prefer `lib.mkIf`, `lib.mkDefault`, or `lib.mkForce` to manage option merges.
- When overriding packages, prefer `override` or `overrideAttrs` explicitly.
- Use `pkgs` from arguments; do not re-import nixpkgs inside modules.
- Favor option merges over duplicating blocks between machines.

### Error Handling and Safety
- Use `assert` or `lib.assertMsg` for non-obvious constraints.
- Keep `specialArgs` or `inputs` wired through `flake.nix` only.
- Avoid hardcoding system-specific paths unless required (use `${pkgs...}`).
- Be cautious with secrets; prefer external secrets tooling if added later.

### Dependencies and Environment
- Keep `home.packages` and `environment.systemPackages` sorted or grouped.
- When adding system services, keep related settings together.
- Prefer environment variables in `environment.sessionVariables`.
- Keep per-host packages in machine configs, not shared modules.

### Shell Hooks
- If a shell hook performs installs, explain it in a comment.
- Avoid destructive steps; keep hooks idempotent when possible.
- Document any required external binaries in the shell definition.

## Git Practices (from config)
- Git is configured to sign commits; do not disable signing.
- Default branch is `main`.
- Use `nvim` as the editor.
- Prefer small, focused commits if asked to commit.

## Repository-Specific Notes
- `nix_config/flake.nix` defines three NixOS systems. Use those names.
- `nix-darwin/flake.nix` defines the `PC0099` darwin host.
- Dev shell `xikolo` installs Ruby, Node, and toolchains; it runs `yarn install`.
- Keep `home-manager` imports under `nix_config/nixos_modules/default.nix`.
- `nix_config/programs/default.nix` aggregates Home Manager program modules.

## Cursor/Copilot Rules
- No `.cursor/rules/`, `.cursorrules`, or
  `.github/copilot-instructions.md` files were found.

## When Adding New Files
- Use ASCII unless the file already uses Unicode.
- Keep module files small and focused.
- Prefer placing program configs under `nix_config/programs/`.
- For new machines, add to `nix_config/machines/` and wire in `flake.nix`.

## Documentation Updates
- Update this file if you add new commands or tooling.
- Add brief notes to `servers/README.md` if server setup changes.
