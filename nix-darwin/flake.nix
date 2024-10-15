{
  description = "Work Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, home-manager, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.kitty
          pkgs.kitty-themes
          pkgs.neovim
          pkgs.tmux
        ];

      fonts.packages =
        [
          (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];

      system.defaults = {
        dock.autohide = true;
        dock.persistent-apps = [
         "${pkgs.kitty}/Applications/Kitty.app"
         "Applications/Google Chrome.app"
         "Applications/Firefox.app"
         "Applications/Slack.app"
         "Applications/pgAdmin 4.app"
        ];
        finder.FXPreferredViewStyle = "clmv";
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.AppleShowAllExtensions = true;
        NSGlobalDomain.KeyRepeat = 2;
      };

      users.users.armin.home = "/Users/armin";
      users.users.armin.name = "armin";

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#PC0099
    darwinConfigurations."PC0099" = nix-darwin.lib.darwinSystem {
      modules = [
       configuration
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."PC0099".pkgs;
  };
}
