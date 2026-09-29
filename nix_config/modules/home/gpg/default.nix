{ ... }:
{
  flake.modules.homeManager.gpg =
    { pkgs, ... }:
    {
      # The keyring itself is not managed here: the public key is published on
      # a keyserver, so gnupg fetches it on demand and `~/.gnupg` stays mutable
      # (which it has to be, since the secret keys live in private-keys-v1.d).
      services.gpg-agent = {
        enable = true;

        enableSshSupport = true;
        pinentry = {
          package = pkgs.pinentry-qt;
        };
      };
    };
}
