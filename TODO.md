# TODO: Migrate from Hyprland to Niri + Noctalia Shell

Goal: run [niri](https://niri.wf/) as the Wayland compositor with the
[Noctalia](https://noctalia.dev/) desktop shell, replacing Hyprland, Waybar,
Wofi, Mako, hyprpaper, hyprlock, hypridle and clipse.

References:
- NixOS `programs.niri`: nixpkgs `nixos/modules/programs/wayland/niri.nix`
- NixOS `programs.noctalia` + `services.displayManager.noctalia-greeter`
- Noctalia docs: https://docs.noctalia.dev/noctalia/
- Reference config: https://github.com/vimjoyer/nixconf/blob/main/wrappedPrograms/niri.nix

## Locked decisions

1. niri runs alongside Hyprland first; Hyprland is removed once niri is
   verified (session switchable via the greeter).
2. Official nixpkgs modules only: `programs.niri` (NixOS) and
   `wayland.windowManager.niri` (Home Manager). No `nix-wrapper-modules`.
3. Adopt Noctalia Shell: bar, launcher, control center, notifications,
   wallpaper, lock screen and idle all come from Noctalia.
4. Lock/idle: Noctalia's built-in lock screen + idle (no swaylock/swayidle).
5. Login: replace tuigreet with `noctalia-greeter` (session picker, both
   sessions listed during the parallel phase).
6. Noctalia settings are authored declaratively in Nix via
   `programs.noctalia.settings` (HM); GUI overrides are folded back.

## Phase 0 - Baseline

- [x] Branch `niri` created from `master` (dendritic layout already merged).
- [x] Verified session files: `niri-26.04` ships
      `share/wayland-sessions/niri.desktop`, `hyprland-0.56.2` ships
      `hyprland.desktop` (+ `hyprland-uwsm.desktop`).

## Phase 1 - NixOS: niri session + Noctalia greeter

- [x] `modules/nixos/desktop/niri.nix`: `programs.niri.enable = true`.
- [x] `modules/nixos/desktop/hyprland.nix`: `programs.hyprland.enable = true`
      (temporary, fallback session only; removed in Phase 5).
- [x] `modules/nixos/desktop/noctalia.nix`: `programs.noctalia.enable = true`
      (no `systemd.enable`: would also start under Hyprland during the
      parallel phase) + `programs.noctalia.recommendedServices.enable = true`
      (NetworkManager/Bluetooth already on; rest is `mkDefault`) +
      `services.displayManager.noctalia-greeter.enable = true`.
- [x] `modules/nixos/core/desktop.nix`: drop manual `services.greetd.settings`
      (noctalia-greeter owns `greetd.enable` + `default_session.command` via
      `mkDefault`) and the Hyprland-only `xdg.portal` bits
      (`extraPortals = [ xdg-desktop-portal-hyprland ]`,
      `config.common.default = "hyprland"`, `wlr.enable = false`); keep
      `xdg.portal.enable = true` (niri/hyprland modules set the rest).
- [x] Wire all three modules into `modules/nixos/shared.nix`.

Verify:
- [x] `nix flake show nix_config`
- [x] build all three hosts:
  - `nixos-rebuild build --flake nix_config#armin-pc`
  - `nixos-rebuild build --flake nix_config#armin-laptop`
  - `nixos-rebuild build --flake nix_config#armin-work-laptop`
- [x] `nix eval` greeter command = `noctalia-greeter-session`,
      `displayManager.defaultSession = "niri"` (niri module default),
      both sessions present in `services.displayManager.sessionPackages`.
- [x] Boot test: greeter lists niri + Hyprland; logging into niri starts an
      empty niri session.
- [x] Commit.

## Phase 2 - Home Manager: niri settings

- [x] `modules/home/desktop/niri.nix`: `wayland.windowManager.niri.settings`
      with the translated config (see mapping table below), incl.
      `spawn-at-startup` for Noctalia.
- [x] Wire into `modules/home/desktop/desktop-programs.nix`.

Verify:
- [x] Host builds pass (HM `checkConfig` runs `niri validate`).
- [x] Commit.

### Hyprland -> niri mapping

| Hyprland | niri |
| --- | --- |
| `monitor = eDP-1, 1920x1080@1200,1560` | `output = "eDP-1" { mode = "1920x1080" position = { x = 1200; y = 1560; } }` |
| `monitor = DP-4, 1920x1200@0,0,90` | `output = "DP-4" { mode = "1920x1200" transform = "90" position = { x = 0; y = 0; } }` |
| `monitor = DP-3, 1920x1200@1200,360` | `output = "DP-3" { mode = "1920x1200" position = { x = 1200; y = 360; } }` |
| `gaps_in 2` / `gaps_out 2` | `layout { gaps = 2 }` |
| `border_size 2`, `border_color active #33ccff` | `layout { border = { width = 2 } focus-ring = { width = 2 active-color = "#33ccff" } }` |
| `follow_mouse 1` | `input { focus-follows-mouse = {} }` |
| `touchpad:natural_scroll yes` | `input { touchpad { natural-scroll = false } }` (check current value) |
| `bind SUPER Q ...` etc. | `binds { "Mod+Q".spawn = "kitty" ... }` |
| clipse window-rule (float, 622x652) | `window-rule { class-match "clipse" float = {} size = { width = 622; height = 652; } }` |
| XWayland via Hyprland | `xwayland-satellite` (HM `xwaylandSatellitePackage` default) |
| hyprpaper swaybg | Noctalia `[wallpaper]` (Phase 3) |
| hyprlock | Noctalia `[lockscreen]` + `noctalia msg session lock` |
| hypridle | Noctalia `[idle]` |

Keybind conflicts to resolve in Phase 2:
- `Mod+S`: screenshot (grim/slurp) -> `Print`; Noctalia control-center keeps `Mod+S`.
- `Mod+R` wofi launcher -> Noctalia launcher `Mod+Space` (default).
- `Mod+L`: Noctalia `noctalia msg session lock`.
- `Mod+Comma`: Noctalia settings.
- `Mod+V` clipse: keep clipse or switch to Noctalia clipboard (decide in Phase 3).
- Media/brightness binds need `allow-when-locked = true` in niri.

niri KDL gotchas: multiple `spawn-at-startup`/`window-rule`/`binds` nodes must
use the `_children` form in the HM attrset; no `stay_focused` rule; blur only
in niri >= 26.04; start Noctalia with `noctalia --daemon`.

## Phase 3 - Home Manager: Noctalia shell

- [x] `modules/home/desktop/noctalia.nix`: `programs.noctalia.enable = true` +
      `programs.noctalia.settings`:
      - `[theme]` `mode = "dark"`, `source = "builtin"`, `builtin = "Catppuccin"`.
      - `[wallpaper]` -> `wallpapers/night-mountain.jpg` (same file hyprpaper used).
      - bar widgets mirroring the current Waybar set (workspaces via Noctalia's
        niri integration, window title, battery, network, bluetooth, clock).
      - `[lockscreen]`, `[idle]` (lock on idle timeout).
      - niri integration settings (window rules for Noctalia surfaces).
- [x] niri `spawn-at-startup "noctalia" "--daemon"` (Phase 2 file).
- [x] Keep `programs.noctalia.systemd.enable` (HM) OFF during parallel phase.

Verify:
- [x] Host builds pass (`noctalia config validate` runs at build time).
- [x] Boot test: niri starts Noctalia; bar/launcher/lock/idle work.
- [x] Commit.

## Phase 4 - End-to-end verification

- [ ] Screenshots: `Print` -> `grim -g "$(slurp)"`.
- [ ] Portals: file chooser + screencast via `xdg-desktop-portal-gnome`.
- [ ] XWayland apps (e.g. a quick x11 app) via `xwayland-satellite`.
- [ ] Noctalia lock (`Mod+L`) and idle blanking.
- [ ] All three hosts build.

## Phase 5 - Remove Hyprland

- [ ] Drop `modules/nixos/desktop/hyprland.nix` (+ `shared.nix` entry).
- [ ] Drop HM modules `hyprland`, `waybar`, `wofi`, `hyprpaper` and their
      `desktop-programs.nix` entries (files deleted).
- [ ] Relocate the bind tools that currently live in the hyprland HM module's
      `home.packages` (`grim`, `slurp`, `wl-clipboard`, `clipse`, `playerctl`,
      `brightnessctl`, `pwvucontrol`) into the niri module; `kitty`/`firefox`
      already come from `home.nix`.
- [ ] Keep `imv`, `mpv`, `easyeffects`, `kitty`, `yazi`.
- [ ] Verify builds; boot; commit.

## Gotchas

- Do NOT enable `programs.noctalia.systemd.enable` (NixOS or HM) during the
  parallel phase: the unit targets `graphical-session.target`, which Hyprland
  also reaches, so Noctalia would run under Hyprland and fight Waybar/Mako.
- `services.hyprpaper` is scoped to `hyprland-session.target` so the
  Hyprland-only tool does not start (and fail-loop) under niri.
- Noctalia greeter sets `services.greetd` via `mkDefault`; the old manual
  greetd block in `core/desktop.nix` must be deleted, not overridden.
- Noctalia greeter needs `services.greetd.settings.default_session.user` to
  exist (NixOS greetd default user `greeter` suffices).
- Noctalia greeter disables the previous auto-login (`initial_session`); the
  session is chosen at the login screen.
- `programs.niri` sets `displayManager.defaultSession` and the niri portal
  defaults; `programs.hyprland` adds `configPackages = [ hyprland ]`.
  Don't also force `xdg.portal.config.common.default` by hand.
- `nixos-rebuild` flake URI is unchanged: `nix_config#<host>`.
