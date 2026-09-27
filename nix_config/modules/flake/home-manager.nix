{ inputs, ... }:
{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        inputs.hermes-agent.homeManagerModules.default
        inputs.sops-nix.homeManagerModules.sops
      ];
    };
  };
}
