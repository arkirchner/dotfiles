# Installation of server with Nixos infect

```
curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | \
  NIX_CHANNEL=nixos-24.11 \
  NIXOS_CONFIG=https://raw.githubusercontent.com/arkirchner/dotfiles/refs/heads/master/servers/configuration.nix \
  bash -x

```
