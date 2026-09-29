{ ... }:
{
  flake.modules.homeManager.gpg =
    { pkgs, ... }:
    {
      # pinentry-gnome3 is GTK3 and picks up the GTK theme, unlike pinentry-qt
      # (Qt6/Fusion, which ignored the desktop theme entirely). It needs gcr_3
      # in the session so its D-Bus activatable prompter
      # (org.gnome.keyring.SystemPrompter) can start without GNOME.
      home.packages = [ pkgs.gcr_3 ];

      # Catppuccin Mocha to match the Noctalia shell. `gtk.enable` is opt-in in
      # Home Manager, so it has to be set for the options below to be written.
      # GTK4 is left alone: only the GTK3 pinentry dialog is being restyled.
      gtk = {
        enable = true;
        colorScheme = "dark";
        theme = {
          name = "catppuccin-mocha-blue-standard";
          package = pkgs.catppuccin-gtk.override { variant = "mocha"; };
        };
        gtk4.theme = null;
      };

      # The keyring itself is not managed here: the public key is published on
      # a keyserver, so gnupg fetches it on demand and `~/.gnupg` stays mutable
      # (which it has to be, since the secret keys live in private-keys-v1.d).
      services.gpg-agent = {
        enable = true;

        enableSshSupport = true;
        pinentry = {
          package = pkgs.pinentry-gnome3;
        };
      };
    };
}
