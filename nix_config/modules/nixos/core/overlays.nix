{ ... }:
{
  flake.modules.nixos.overlays = {
    nixpkgs.overlays = [
      (_final: prev: {
        python313Packages = prev.python313Packages.override {
          overrides = _pyfinal: pyprev: {
            aioboto3 = pyprev.aioboto3.overridePythonAttrs (_old: {
              doCheck = false;
            });
            fastmcp = pyprev.fastmcp.overridePythonAttrs (_old: {
              doCheck = false;
            });
          };
        };
      })
    ];
  };
}
