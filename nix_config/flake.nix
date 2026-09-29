{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    # Fork of nix-community/nvf. Its only local commit (c53fd06) merges
    # upstream main and resolves a tex.nix conflict in favour of ltex-ls-plus.
    nvf.url = "github:arkirchner/nvf/main";

    hermes-agent.url = "github:NousResearch/hermes-agent/main";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
