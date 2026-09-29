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

- [ ] `core/desktop.nix:4` `services.dbus.enable = true` — NixOS default.
- [ ] `core/desktop.nix:13-17` `services.xserver.xkb` block — default is already
      `layout = "us"`, `variant = ""`, and niri/xwayland-satellite ignore
      `/etc/X11/xkb` anyway (`input.keyboard.xkb.layout` in the niri config is
      what applies).
- [ ] `core/bluetooth.nix:6` `hardware.bluetooth.powerOnBoot = true` — default.
- [ ] `home/home.nix` `tmux`, `kitty` — already added by `programs.tmux` /
      `programs.kitty`. Verified duplicates in `home.packages`: `kitty`, `tmux`,
      `niri` (each listed twice).
- [ ] `services/redis.nix:7` `databases = 8192` — leftover tuning, no consumer.
- [ ] `shells/codeocean.nix`, `shells/wave_walker.nix` — use `import <nixpkgs>`,
      which needs `NIX_PATH`, and are not reachable from the flake (only
      `./modules` is imported). Convert to `devShells` in the main flake or move
      them out of this repo.
- [ ] `nix_config/wallpapers/.DS_Store` (tracked) and the 8 unused wallpapers
      (~9 MB; only `night-mountain.jpg` is referenced).
- [ ] `modules/home/desktop/{imv,mpv,easyeffects}` — 8 lines each for one
      boolean; inline them into `desktop-programs.nix`.
- [ ] `modules/home/fish/default.nix:19` `nixos-update` alias — duplicates
      `nix.gc` in `core/nix.nix:4-8` and uses legacy `nix-env --delete-generations`.
      Reduce to `sudo nixos-rebuild switch`.
- [ ] `modules/home/opencode/skills/` — not deployed (only `agents/` and
      `AGENTS.md` are, `opencode/default.nix:84-85`). Deploy it or delete it.
- [ ] `packages/rails-mcp-server/default.nix:9` — `stdenv.mkDerivation` is
      deprecated, use `stdenvNoCC.mkDerivation`.

Verify:
```
nix eval --impure --json --expr 'let f = builtins.getFlake (toString ./.);
  hm = f.nixosConfigurations.armin-pc.config.home-manager.users.armin;
  in (let n = map (p: p.pname or p.name) hm.home.packages;
      in builtins.filter (x: builtins.length (builtins.filter (y: y == x) n) > 1) n)'
```

## 3. Contradictions to resolve

- [ ] **`services/podman.nix`: pick one container runtime.** `dockerCompat = false`
      sits directly under the comment "Create a `docker` alias for podman"
      (lines 12-13), and `virtualisation.docker.enable = true` runs the Docker
      daemon next to Podman.
- [ ] **`services/podman.nix:35-44`: delete `systemd.services.qemu-user-static`.**
      It runs a `--privileged` Docker container on `multi-user.target` at every
      boot to register binfmt handlers that `boot.binfmt.emulatedSystems` (lines
      31-32) already registers.
- [ ] **`home/desktop/niri/default.nix:21-52`: move the `output` blocks per host.**
      eDP-1/DP-3/DP-4 with hardcoded positions is one docked 720s layout, shared
      by all three hosts (harmless today only because unknown outputs are
      ignored). Move monitor/position config into per-host HM modules.
- [ ] **Server-ish services on every host.** nomad (server *and* client),
      postgresql, redis and libvirtd are all in `nixos/shared.nix`, so the work
      laptop runs a nomad server and a database. Move them to the hosts that
      need them.
- [ ] **sops is PGP/YubiKey-only** (`home/hermes-agent/default.nix`,
      `.sops.yaml`): every `home-manager` activation needs the card + PIN, and a
      failed decrypt aborts activation. Consider an age key as fallback.
      Related: `users.users.armin.linger = true` (`core/users.nix:14`) exists
      only for this service.
- [ ] **`flake.nix:5,7`: pin and document the non-nixpkgs inputs.**
      `github:arkirchner/nvf` and `github:NousResearch/hermes-agent` follow the
      default branch with no branch ref. Pin a branch and add a comment saying why
      the fork is needed.
- [ ] **`pkgs.ruby_4_0` is hardcoded in 3 places** (`editors/nvf.nix:8`,
      `shells/*`, `packages/rails-mcp-server/default.nix`) while nixpkgs `ruby` is
      3.4.9. Decide whether the 4.0 series is a requirement.
- [ ] **Deduplicate host wiring**: `home-manager.users.armin.imports = [ hm.armin ]`
      is copy-pasted in all three `modules/hosts/*/configuration.nix`; it belongs
      in `modules/nixos/shared.nix`.

Verify: `nix flake check` + `nixos-rebuild build --flake nix_config#armin-pc`
(and the other two hosts).

## 4. Documentation and tooling

- [ ] **Fix `AGENTS.md`.** It documents `nix_config/nixos_modules/**`,
      `nix_config/programs/**`, `nix_config/machines/*/`, `nix-darwin/flake.nix`
      and `servers/` — none of which exist anymore (everything moved to
      `nix_config/modules/`).
- [ ] **Add a formatter.** No `formatter` output exists, so the `nix fmt`
      mentioned in AGENTS.md does not work. Use `nixfmt-rfc-style` or `treefmt`.
- [ ] **Run `nix flake check` in CI** (or a pre-commit hook) so duplicate
      attributes and unused inputs fail early.
- [ ] **`.gitignore`**: replace the stale `linux/.bashrc.d/keys` entry with
      `result`, `result-*`, `.direnv/`.
- [ ] **Optional Nix settings**: `nix.settings.auto-optimise-store = true`
      (store optimisation is currently off), and `nix.settings.trusted-users`
      with `@wheel` if you want unprivileged `nix` (default is `["root"]`).

## 5. Open questions (answer before implementing section 3)

- [ ] Is Docker still needed at all, or is Podman with `dockerCompat = true` enough?
- [ ] Which host(s) should run nomad / postgres / redis?
- [ ] Is the `python313Packages` overlay (`core/overlays.nix`) still required?
      `aioboto3`/`fastmcp` still have pytest-based checks upstream, but verify
      they fail without `doCheck = false` before removing it.
- [ ] Is `postgresql.package = pkgs.postgresql_16` (16.15, two majors behind
      unstable) a hard requirement? Pinning means no security updates.
- [ ] Are `networking.extraHosts` entries `test.local` / `longhorn.test.local`
      still used?

---

Note: the previous contents of this file were the completed Hyprland → niri +
Noctalia migration plan (kept in git history at commit `ef31571`, including the
Hyprland → niri settings mapping table).
