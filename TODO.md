# TODO: Migrate `nix_config` to the Dendritic Pattern (flake-parts)

Goal: make every `.nix` file a self-contained flake-parts module, so that hosts,
NixOS features, and Home Manager features compose by *declaration* instead of
path-based `imports`.

Reference reading:
- Pattern: https://github.com/mightyiam/dendritic
- `import-tree`: https://github.com/vic/import-tree
- `flake.modules`: https://flake.parts/options/flake-parts-modules.html

## Definition of done

- [ ] `nix_config/flake.nix` is <= ~15 lines and contains only `inputs` + `mkFlake`.
- [ ] Every file under `nix_config/modules/` is a flake-parts module.
- [ ] No module imports another module by path (`imports = [ ../programs ]` is gone).
- [ ] Features expose `flake.modules.nixos.<name>` and `flake.modules.homeManager.<name>`.
- [ ] Hosts are declared in one place as `flake.nixosConfigurations.<host>`.
- [ ] All three hosts build:
  - `nixos-rebuild build --flake /home/armin/Documents/dotfiles/nix_config#armin-pc`
  - `nixos-rebuild build --flake /home/armin/Documents/dotfiles/nix_config#armin-laptop`
  - `nixos-rebuild build --flake /home/armin/Documents/dotfiles/nix_config#armin-work-laptop`

## Concepts (short version)

- Each `.nix` file is a flake-parts module; `import-tree` imports the whole tree.
- A file usually does one thing: register a deferred module, e.g.
  `flake.modules.nixos.foo = { ... }: { ... };`
- A NixOS config is built by listing deferred modules:
  `modules = [ config.flake.modules.nixos.boot ... ];`
- Values are shared through the top-level `config`, not `specialArgs`.
- `import-tree` ignores any path whose name starts with `_` (use it for raw
  files such as hardware scans that must not be evaluated as flake-parts modules).

---

## Current state (inventory)

| Current path | Class | Notes |
| --- | --- | --- |
| `flake.nix` | flake | 3 hosts, all use `specialArgs = { inherit inputs; }` |
| `nixos_modules/default.nix` | nixos + hm | Monolith: boot, plymouth, users, packages, pam-u2f, overlays, AND the whole `home-manager.users.armin` block |
| `nixos_modules/nvf.nix` | nixos | `programs.nvf` |
| `nixos_modules/qmk.nix` | nixos | |
| `nixos_modules/redis.nix` | nixos | |
| `nixos_modules/vpn.nix` | nixos | |
| `nixos_modules/libvirtd.nix` | nixos | |
| `nixos_modules/postgresql/` | nixos | |
| `nixos_modules/podman/` | nixos | |
| `nixos_modules/nomad/` | nixos | |
| `nixos_modules/thunar/` | nixos | `programs.thunar`, `services.gvfs` |
| `nixos_modules/desktop_programs/*` | **home-manager** | hyprland, waybar, wofi, hyprpaper, imv, mpv, easyeffects |
| `programs/*` | **home-manager** | fish, tmux, kitty, vscode, gpg, git, opencode, hermes-agent (aggregated by `programs/default.nix`) |
| `programs/{bash,oh_my_posh,openvpn,vale}` | **home-manager** | NOT in the aggregator -> currently dead |
| `machines/x600/configuration.nix` | nixos | thin host (`networking.hostName`, hardware import) |
| `machines/720s/configuration.nix` | nixos | thin host |
| `machines/dell_5450/configuration.nix` | nixos | thin host |
| `machines/*/hardware-configuration.nix` | nixos | raw hardware scans |
| `machines/720s/programs.nix` | - | **dead** (never imported) |
| `packages/rails-mcp-server/` | package | `callPackage`-style derivation |
| `shells/*` | devshells | not part of NixOS hosts |
| `secrets/`, `.sops.yaml` | - | sops-nix data |

Note: `programs/bash`, `programs/oh_my_posh`, `programs/openvpn`, `programs/vale`
and `machines/720s/programs.nix` look unused today. Mention/remove during the
migration (do not delete before confirming).

---

## Target layout

```
nix_config/
  flake.nix                      # inputs + mkFlake + import-tree
  flake.lock
  modules/
    flake/
      flake-parts.nix            # imports flake-parts.flakeModules.modules
      systems.nix                # systems = [ "x86_64-linux" ]
      home-manager.nix           # NixOS<->HM integration module
      devshells.nix              # optional: port shells/codeocean + shells/xikolo
      packages.nix               # optional: port packages/rails-mcp-server
    nixos/
      core/
        boot.nix plymouth.nix nix.nix networking.nix users.nix
        audio.nix bluetooth.nix graphics.nix fonts.nix desktop.nix
        session.nix pam-u2f.nix overlays.nix packages.nix
      services/
        postgresql.nix podman.nix nomad.nix redis.nix vpn.nix libvirtd.nix qmk.nix
      desktop/
        thunar.nix
      editors/
        nvf.nix
    home/
      core/
        home.nix                 # home.packages, stateVersion
        fish.nix git.nix gpg.nix tmux.nix kitty.nix vscode.nix opencode.nix hermes-agent.nix
        programs.nix             # profile: imports the program set
      desktop/
        hyprland.nix waybar.nix wofi.nix hyprpaper.nix imv.nix mpv.nix easyeffects.nix
        desktop-programs.nix     # profile: imports the desktop set
    hosts/
      x600/
        default.nix              # flake.nixosConfigurations.armin-pc
        hardware.nix             # registers deferred NixOS module
        _hardware-configuration.nix   # raw scan (underscore = ignored by import-tree)
      _720s/ ...       # same shape for armin-laptop
      _dell_5450/ ...  # same shape for armin-work-laptop
      home/
        armin-pc.nix armin-laptop.nix armin-work-laptop.nix   # per-host HM user
```

Do the move in phases and keep each phase buildable.

---

## Phase 0 - Baseline and safety net

- [ ] Create a branch: `git switch -c dendritic`.
- [ ] Record current builds so you can diff later:
  - `nixos-rebuild build --flake /home/armin/Documents/dotfiles/nix_config#armin-pc`
  - repeat for `armin-laptop` and `armin-work-laptop`.
- [ ] `git add -A && git commit -m "chore: baseline before dendritic migration"`.

## Phase 1 - Bootstrap flake-parts

- [ ] Add inputs `flake-parts` and `import-tree` to `flake.nix`; keep the rest.
- [ ] Replace `outputs` with the one-liner.

```nix
# nix_config/flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nvf.url = "github:arkirchner/nvf";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
```

- [ ] Add the two bootstrap modules:

```nix
# modules/flake/flake-parts.nix
{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];
}
```

```nix
# modules/flake/systems.nix
{
  systems = [ "x86_64-linux" ];
}
```

- [ ] Verify: `nix flake show path:/home/armin/Documents/dotfiles/nix_config` (expect no hosts yet, no errors).

## Phase 2 - NixOS feature modules

Split `nixos_modules/default.nix` into one file per feature. Pattern:

```nix
# modules/nixos/core/boot.nix
{ ... }:
{
  flake.modules.nixos.boot = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = 0;
  };
}
```

Checklist of features to extract from the monolith:
- [ ] bootloader (`boot.loader.systemd-boot*`, `boot.loader.timeout`)
- [ ] plymouth / silent boot (`boot.plymouth`, `consoleLogLevel`, `kernelParams`)
- [ ] `nix.settings.experimental-features` + `nix.gc`
- [ ] `nixpkgs.config.allowUnfree`
- [ ] `nixpkgs.overlays` (python313Packages aioboto3/fastmcp overrides)
- [ ] networking (`networkmanager`, `extraHosts`, `firewall.extraCommands`)
- [ ] locale/time (`time.timeZone`, `i18n.*`, `services.xserver.xkb`)
- [ ] users (`users.users.armin`, groups, `linger`)
- [ ] dbus / fwupd / dconf / fish / steam
- [ ] xdg.portal + greetd (session)
- [ ] hardware: graphics, bluetooth, blueman, rtkit, pipewire
- [ ] fonts (`fonts.packages`)
- [ ] `environment.systemPackages` + `environment.sessionVariables`
- [ ] `security.pam.u2f`
- [ ] `system.stateVersion` (only in the host module, not shared)

Move the existing service modules:
- [ ] `nixos_modules/{qmk,redis,vpn,libvirtd}.nix` -> `modules/nixos/services/*.nix`, each wrapped as `flake.modules.nixos.<name>`.
- [ ] `nixos_modules/{postgresql,podman,nomad,thunar}/default.nix` -> same, keeping subfiles.
- [ ] `nixos_modules/nvf.nix` -> `modules/nixos/editors/nvf.nix` as `flake.modules.nixos.nvf`.
- [ ] `nixos_modules/desktop_programs/*` are Home Manager modules -> move to Phase 3.

Verify after this phase by wiring one host with the new modules (Phase 4).

## Phase 3 - Home Manager modules

- [ ] Move each `programs/<x>/default.nix` to `modules/home/<x>.nix`, wrapped:

```nix
# modules/home/tmux.nix
{ ... }:
{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.fzf ];
      programs.tmux.enable = true;
      # ...
    };
}
```

- [ ] Replace `programs/default.nix` (a list) with a profile module:

```nix
# modules/home/programs.nix
{ config, ... }:
{
  flake.modules.homeManager.programs = {
    imports = with config.flake.modules.homeManager; [
      fish tmux kitty vscode gpg git opencode hermes-agent
    ];
  };
}
```

- [ ] Move `nixos_modules/desktop_programs/*` to `modules/home/desktop/*` as
      `flake.modules.homeManager.<name>`, plus a `desktop-programs` profile module.
- [ ] Move the `home.packages` list + `home.stateVersion` into a shared
      `flake.modules.homeManager.home`.
- [ ] Keep non-`.nix` assets (e.g. `stay_always_in_tmux`, `tmux.config`, `wofi.css`)
      next to their module; `builtins.readFile ./...` still works.

## Phase 4 - Hosts

- [ ] Convert each `machines/<host>/configuration.nix` into `modules/hosts/<host>/default.nix`:

```nix
# modules/hosts/x600/default.nix
{ config, inputs, ... }:
{
  flake.nixosConfigurations.armin-pc = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.nvf.nixosModules.default
      config.flake.modules.nixos.boot
      config.flake.modules.nixos.home-manager
      config.flake.modules.nixos."nixosConfigurations/armin-pc"
    ];
  };
}
```

- [ ] Put host-specific NixOS config (hostname, quirks, `stateVersion`) in a
      matching entry and let multiple files contribute to the same key:

```nix
# modules/hosts/x600/configuration.nix
{ ... }:
{
  flake.modules.nixos."nixosConfigurations/armin-pc" = {
    networking.hostName = "armin-pc";
    system.stateVersion = "24.11";
  };
}
```

- [ ] Hardware scans: rename to `_hardware-configuration.nix` (underscore so
      `import-tree` skips it) and register it from a wrapper:

```nix
# modules/hosts/x600/hardware.nix
{ ... }:
{
  flake.modules.nixos."nixosConfigurations/armin-pc".imports = [
    ./_hardware-configuration.nix
  ];
}
```

- [ ] Repeat for `720s` (armin-laptop) and `dell_5450` (armin-work-laptop).
- [ ] Optional DRY helper: a `flake/nixos-hosts.nix` option `nixosHosts` that
      maps to `flake.nixosConfigurations` (see bivsk/GaetanLepage examples).

## Phase 5 - Home Manager <-> NixOS integration

This is the part that currently lives in `nixos_modules/default.nix`:

```nix
home-manager.backupFileExtension = "backup";
home-manager.useGlobalPkgs = true;
home-manager.useUserPackages = true;
home-manager.sharedModules = [
  inputs.hermes-agent.homeManagerModules.default
  inputs.sops-nix.homeManagerModules.sops
];
home-manager.users.armin = { imports = (import ../programs) ++ (import ./desktop_programs); home.stateVersion = "24.05"; };
```

- [ ] Create a flake-parts module. Capture the HM modules in a `let` so the
      inner NixOS module does not shadow flake-parts `config`:

```nix
# modules/flake/home-manager.nix
{ inputs, config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  flake.modules.nixos.home-manager = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      sharedModules = [
        inputs.hermes-agent.homeManagerModules.default
        inputs.sops-nix.homeManagerModules.sops
      ];
      users.armin.imports = [
        hm.home
        hm.programs
        hm.desktop-programs
        hm."homeConfigurations/armin-pc" # per-host; set per host instead
      ];
    };
  };
}
```

- [ ] Prefer declaring `home-manager.users.armin.imports` in the host module and
      only share `useGlobalPkgs`/`sharedModules` globally.
- [ ] Add per-host HM file, e.g. `modules/hosts/home/armin-pc.nix`:

```nix
{ config, ... }:
{
  flake.modules.homeManager."homeConfigurations/armin-pc" = {
    home.stateVersion = "24.05";
    imports = with config.flake.modules.homeManager; [ programs desktop-programs ];
  };
}
```

- [ ] Port `inputs.sops-nix.nixosModules.sops` if any NixOS-level secrets are needed.

## Phase 6 - Remaining outputs (optional)

- [ ] `packages/rails-mcp-server` -> `flake.packages.<system>.rails-mcp-server = pkgs.callPackage ./rails-mcp-server { };` in `modules/flake/packages.nix`.
- [ ] `shells/codeocean.nix`, `shells/wave_walker.nix`, `shells/xikolo/flake.nix` -> `flake.devShells.<system>.<name>`.

## Phase 7 - Cutover and cleanup

- [ ] Delete `nixos_modules/` and `programs/` and `machines/` once nothing references them.
- [ ] Remove `specialArgs = { inherit inputs; }` (read inputs via flake-parts args
      or `inputs.self.modules...`). Add a `generic` module only if a lower-level
      module truly needs `inputs`:

```nix
# modules/flake/inputs.nix
{ inputs, ... }:
{
  flake.modules.generic.inputs = { ... }: {
    _module.args.inputs = inputs;
  };
}
```

- [ ] Confirm dead files before deleting: `programs/{bash,oh_my_posh,openvpn,vale}`,
      `machines/720s/programs.nix`.
- [ ] Final verification:
  - `nix flake show path:/home/armin/Documents/dotfiles/nix_config`
  - build all three hosts (commands in Definition of done).
- [ ] Commit.

---

## Gotchas

- **Hardware scans must not be top-level modules.** `import-tree` would evaluate
  them as flake-parts modules and fail on undeclared options. Underscore-prefix
  the file and import it from a wrapper module.
- **`config` shadowing.** Inside a deferred NixOS module, `config` is the NixOS
  config, not flake-parts config. Capture `config.flake.modules...` in a `let`
  before defining the inner module (see Phase 5).
- **`flake.modules` needs the extra module.** Without
  `inputs.flake-parts.flakeModules.modules` in `imports`, `flake.modules.*` is
  undeclared.
- **Attribute name collisions.** `flake.modules.nixos.home-manager` and
  `flake.modules.homeManager.home-manager` coexist (different classes), but two
  files registering the same class+name must be mergeable deferred modules.
- **`home.stateVersion` vs `system.stateVersion`** live in different classes.
- **`specialArgs` is the documented anti-pattern.** Prefer the top-level `config`
  for sharing; only pass `inputs` down if unavoidable.
- **`nixos-rebuild` flake URI is unchanged**: still `nix_config#<host>`.
- **`programs.fish.enable` (NixOS)** and `programs.fish` (HM) are different
  options; the monolith sets both.

## Optional follow-ups

- [ ] Adopt `flake-file` to declare inputs from within modules instead of `flake.nix`.
- [ ] Adopt `vic/den` for aspect-oriented composition (what vic/vix moved to).
- [ ] Add `treefmt-nix` and an `nix flake check` CI job.
- [ ] Consider `colmena`/`deploy-rs` once hosts are declarative.
