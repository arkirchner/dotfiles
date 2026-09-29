# TODO: Config review cleanup

Findings from a full review of the nix config (2026-09-29). Ordered by impact.
Each group ends with the command that verifies it.

Baseline before starting: `nix flake check` passes, and
`nix build .#nixosConfigurations.armin-pc.config.home-manager.users.armin.xdg.configFile."niri/config.kdl".source`
passes `niri validate`.

## 1. Bugs — config that does not do what it looks like

- [x] **`modules/home/gpg/default.nix`: `programs.gpg` was inert.** Resolved by
      dropping the block (2026-09-29) and keeping only `services.gpg-agent`: the
      public key is published on a keyserver, so there is nothing to import, and
      `mutableKeys = false` would have replaced `~/.gnupg/pubring.kbx` with an
      immutable store link built from a stale 2023 export of the key (the live
      subkeys were rotated in 2025/2026). `armin.gpg` deleted with it.
- [x] **`modules/home/gpg/default.nix:7`: typo `disbale-ccid` → `disable-ccid`.**
      Gone with the `programs.gpg` block.
- [x] **`modules/nixos/services/nomad.nix:14`: `alloc_dir = "/var/lib/nomad/allococ_mounts"`**
      (typo `allococ`, and nothing creates the directory). Typo fixed; the
      directory is now declared via
      `systemd.tmpfiles.settings."nomad"."/var/lib/nomad/alloc_mounts".d.mode`;
      stale `TODO:` comment dropped.
- [x] **`modules/home/git/default.nix`: two `settings` attrsets** (lines 11 and 26).
      Merged into one.
- [x] **`modules/nixos/core/packages.nix:11` `samba`** with
      `services.samba.enable = false` (verified) → package removed.
- [x] **`modules/nixos/core/networking.nix:10`: raw-table netbios `CT` rule**
      only exists for samba → removed.
- [x] **Second polkit agent**: `lxqt.lxqt-policykit` in
      `environment.systemPackages` (`core/packages.nix:12`) while Noctalia's
      built-in agent is enabled. No polkit-agent systemd service exists in the
      config (verified: only `polkit` and `polkit-agent-helper@`), so nothing
      ever started it. Package removed; Noctalia's `shell.polkit_agent = true`
      is the only agent.

Verify:
```
nix eval --json '.#nixosConfigurations.armin-pc.config.home-manager.users.armin.programs.gpg.enable'
nix eval --json '.#nixosConfigurations.armin-pc.config.services.nomad.settings.client.alloc_dir'
nix flake check
```

## 2. Dead weight — safe no-op deletions

- [x] `core/desktop.nix:4` `services.dbus.enable = true` — NixOS default.
- [x] `core/desktop.nix:13-17` `services.xserver.xkb` block — default is already
      `layout = "us"`, `variant = ""`, and niri/xwayland-satellite ignore
      `/etc/X11/xkb` anyway (`input.keyboard.xkb.layout` in the niri config is
      what applies).
- [x] `core/bluetooth.nix:6` `hardware.bluetooth.powerOnBoot = true` — default.
- [x] `home/home.nix` `tmux`, `kitty` — already added by `programs.tmux` /
      `programs.kitty`. Both removed; both still resolve via those modules.
      `niri` still appears twice in `home.packages`, but that is upstream: the
      HM `wayland.windowManager.niri` module adds `cfg.package` to
      `home.packages` *and* to `xdg.portal.configPackages`. Not fixable here.
- [x] `services/redis.nix:7` `databases = 8192` — leftover tuning, no consumer.
      Back to the nixpkgs default of 16.
- [x] `shells/codeocean.nix`, `shells/wave_walker.nix` — converted: both now take
      `pkgs` as a function argument instead of `import <nixpkgs>`, and
      `modules/flake/dev-shells.nix` exposes them as
      `devShells.x86_64-linux.{codeocean,wave-walker}`.
      `nix develop nix_config#wave-walker` verified (ruby 4.0.7 +YJIT).
      `shells/xikolo` keeps its own flake and lock file.
- [x] `nix_config/wallpapers/.DS_Store` (tracked) — deleted, and `.DS_Store`
      added to `.gitignore`. The 8 unused wallpapers (~9 MB) were kept on
      purpose; only `night-mountain.jpg` is referenced.
- [x] `modules/home/desktop/{imv,mpv,easyeffects}` — inlined into
      `desktop-programs.nix`; the three directories are gone.
- [x] `modules/home/fish/default.nix:19` `nixos-update` alias — duplicates
      `nix.gc` in `core/nix.nix:4-8` and uses legacy `nix-env --delete-generations`.
      Reduced to `sudo nixos-rebuild switch`.
- [x] `modules/home/opencode/skills/` — nothing to do: the directory was empty
      and untracked, so git never had it. Removed the empty local directory.
- [x] `packages/rails-mcp-server/default.nix:9` — `stdenv.mkDerivation` is
      deprecated, use `stdenvNoCC.mkDerivation`.

Verify:
```
nix eval --impure --json --expr 'let f = builtins.getFlake (toString ./.);
  hm = f.nixosConfigurations.armin-pc.config.home-manager.users.armin;
  in (let n = map (p: p.pname or p.name) hm.home.packages;
      in builtins.filter (x: builtins.length (builtins.filter (y: y == x) n) > 1) n)'
```

## 3. Contradictions to resolve

- [x] **`services/podman.nix`: pick one container runtime.** `dockerCompat = false`
      sat directly under the comment "Create a `docker` alias for podman"
      (lines 12-13), and `virtualisation.docker.enable = true` ran the Docker
      daemon next to Podman. Podman only now: `dockerCompat = true`,
      `virtualisation.docker` gone, and `users.users.armin.extraGroups` swaps
      `docker` for `podman` (the `docker` group no longer exists). Note that
      `services.nomad.enableDocker` *also* defaults to true upstream and would
      have silently re-enabled the daemon — it is now `false`.
- [x] **`services/podman.nix:35-44`: delete `systemd.services.qemu-user-static`.**
      It ran a `--privileged` Docker container on `multi-user.target` at every
      boot to register binfmt handlers that `boot.binfmt.emulatedSystems` (lines
      31-32) already registers. Verified `systemd.services ? qemu-user-static` is
      now false.
- [x] **`home/desktop/niri/default.nix:21-52`: move the `output` blocks per host.**
      Done: the shared niri module keeps everything except the monitors, and
      each host has a `home-manager.nix` defining
      `flake.modules.homeManager."nixosConfigurations/<name>"` with its own
      `output` blocks. armin-pc: DP-1 3840x2160 scale 1.5 at 0,0 (measured with
      `niri msg outputs`; it has no eDP-1/DP-3/DP-4). armin-laptop: eDP-1 only.
      armin-work-laptop: the old eDP-1/DP-4/DP-3 layout. All three rendered
      configs pass `niri validate`.
- [x] **Server-ish services on every host.** nomad (server *and* client),
      postgresql, redis and libvirtd are all in `nixos/shared.nix`, so the work
      laptop ran a nomad server and a database. Resolved as: redis removed
      outright (module and import gone), nomad kept but
      `services.nomad.enable = lib.mkDefault false` so a host has to opt in,
      postgresql and libvirtd stay on every host.
- [ ] **sops is PGP/YubiKey-only** (`home/hermes-agent/default.nix`,
      `.sops.yaml`): every `home-manager` activation needs the card + PIN, and a
      failed decrypt aborts activation. Considered an age key as fallback and
      decided against it (2026-09-29) — PGP-only stays, and with it
      `users.users.armin.linger = true` (`core/users.nix`), which exists only
      for the Hermes service.
- [x] **`flake.nix:5,7`: pin and document the non-nixpkgs inputs.**
      `github:arkirchner/nvf/main` and `github:NousResearch/hermes-agent/main`
      now carry an explicit ref, with a comment above nvf explaining the fork
      (its only local commit, c53fd06, merges upstream main and resolves a
      tex.nix conflict in favour of ltex-ls-plus). The `ref` was added to
      `flake.lock` by hand so the pinned revs did not move.
- [x] **`pkgs.ruby_4_0` is hardcoded in 3 places** (`editors/nvf.nix:8`,
      `shells/*`, `packages/rails-mcp-server/default.nix`) while nixpkgs `ruby` is
      3.4.9. The 4.0 series is a requirement; each of the four sites now says so
      in a comment.
- [x] **Deduplicate host wiring**: `home-manager.users.armin.imports = [ hm.armin ]`
      is now set once in `modules/nixos/shared.nix`; the three host files import
      their own `hm."nixosConfigurations/<name>"` on top of it.

Verify: `nix flake check` + `nixos-rebuild build --flake nix_config#armin-pc`
(and the other two hosts).

## 4. Documentation and tooling

- [x] **Fix `AGENTS.md`.** It documented `nix_config/nixos_modules/**`,
      `nix_config/programs/**`, `nix_config/machines/*/`, `nix-darwin/flake.nix`
      and `servers/` — none of which exist anymore. It now describes the
      `nix_config/modules/` layout, the per-host `home-manager.nix`, the
      devShells, and the fact that untracked files are invisible to this git
      flake.
- [x] **Add a formatter.** `modules/flake/formatter.nix` exposes
      `formatter.x86_64-linux` (a wrapper around treefmt), and
      `treefmt.toml` runs nixfmt and deadnix. The whole repo was formatted once
      in its own commit, so `nix fmt -- --fail-on-change` is now clean.
- [ ] **Run `nix flake check` in CI** (or a pre-commit hook) so duplicate
      attributes and unused inputs fail early. Deliberately not added.
- [x] **`.gitignore`**: the stale `linux/.bashrc.d/keys` entry is replaced by
      `result`, `result-*`, `.direnv/` and `.DS_Store`.
- [x] **Optional Nix settings**: `auto-optimise-store = true` and
      `trusted-users = [ "@wheel" ]` (so the config is `[ "root" "@wheel" ]`)
      in `core/nix.nix`.

## 5. Open questions (answer before implementing section 3)

- [x] Is Docker still needed at all, or is Podman with `dockerCompat = true` enough?
      Answered: podman only, `dockerCompat = true`, no Docker daemon.
- [x] Which host(s) should run nomad / postgres / redis? Answered: nomad off by
      default (a host opts in), postgres and libvirtd everywhere, redis removed.
- [ ] Is the `python313Packages` overlay (`core/overlays.nix`) still required?
      `aioboto3`/`fastmcp` still have pytest-based checks upstream, but verify
      they fail without `doCheck = false` before removing it.
- [ ] Is `postgresql.package = pkgs.postgresql_16` (16.15, two majors behind
      unstable) a hard requirement? Pinning means no security updates. Kept for
      now — no answer yet.
- [ ] Are `networking.extraHosts` entries `test.local` / `longhorn.test.local`
      still used?

---

Note: the previous contents of this file were the completed Hyprland → niri +
Noctalia migration plan (kept in git history at commit `ef31571`, including the
Hyprland → niri settings mapping table).
