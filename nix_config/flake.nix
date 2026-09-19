{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.nvf.url = "github:arkirchner/nvf";

  inputs.hermes-agent.url = "github:NousResearch/hermes-agent";

  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations = {
        armin-pc = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            inputs.nvf.nixosModules.default
            ./machines/x600/configuration.nix
            ./nixos_modules/default.nix
          ];
        };

        armin-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            inputs.nvf.nixosModules.default
            ./machines/720s/configuration.nix
            ./nixos_modules/default.nix
          ];
        };

        armin-work-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            inputs.nvf.nixosModules.default
            ./machines/dell_5450/configuration.nix
            ./nixos_modules/default.nix
          ];
        };
      };
    };
}
