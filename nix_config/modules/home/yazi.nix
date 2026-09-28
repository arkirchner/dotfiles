{ ... }:
{
  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    let
      # Catppuccin Mocha theme for Yazi (accent: mauve). Upstream ships full
      # theme.toml files instead of flavors, so we symlink one into place.
      catppuccinYazi = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "yazi";
        rev = "d62802be39210ea10e54b3e3b09735c6cb9e57c1";
        hash = "sha256-bwzEO8exoBwa19q+jnYjHkaamGl2mhfukIEhDfUCRGI=";
      };

      # syntax highlighting theme referenced by the file above via
      # `syntect_theme = "~/.config/yazi/Catppuccin-mocha.tmTheme"`.
      catppuccinBat = pkgs.catppuccin.override {
        variant = "mocha";
        accent = "mauve";
        themeList = [ "bat" ];
      };
    in
    {
      programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        shellWrapperName = "y";

        extraPackages = with pkgs; [
          file
          fd
          ripgrep
          fzf
          jq
          poppler-utils
          ffmpeg
          imagemagick
        ];
      };

      xdg.configFile."yazi/theme.toml".source =
        "${catppuccinYazi}/themes/mocha/catppuccin-mocha-mauve.toml";

      xdg.configFile."yazi/Catppuccin-mocha.tmTheme".source =
        "${catppuccinBat}/bat/Catppuccin Mocha.tmTheme";
    };
}
