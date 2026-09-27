{ ... }:
{
  flake.modules.nixos.overlays = {
    nixpkgs.overlays = [
      (final: prev: {
        python313Packages = prev.python313Packages.override {
          overrides = pyfinal: pyprev: {
            aioboto3 = pyprev.aioboto3.overridePythonAttrs (old: {
              doCheck = false;
            });
            fastmcp = pyprev.fastmcp.overridePythonAttrs (old: {
              doCheck = false;
            });
          };
        };
      })
    ];
  };
}
