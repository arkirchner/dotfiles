{ ... }:
{
  flake.modules.homeManager.kitty =
    { ... }:
    {
      programs.kitty = {
        enable = true;

        font = {
          name = "JetBrainsMono Nerd Font";
          size = 15;
        };

        settings = {
          background_opacity = "0.8";
          confirm_os_window_close = 0;
          macos_option_as_alt = "yes";
        };

        themeFile = "Catppuccin-Mocha";
        shellIntegration.enableFishIntegration = true;
      };
    };
}
