{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    # Fork of nix-community/nvf. Its only local commit (c53fd06) merges
    # upstream main and resolves a tex.nix conflict in favour of ltex-ls-plus.
    nvf.url = "github:arkirchner/nvf/main";
    # Agent skills installed globally for opencode and Codex. Not a flake.
    rails-consultant = {
      url = "github:thoughtbot/rails-consultant";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
