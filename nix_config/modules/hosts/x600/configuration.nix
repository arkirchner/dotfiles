{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.nixos."nixosConfigurations/armin-pc" =
    { lib, pkgs, ... }:
    let
      model = "inkling-2-mini";
      listenAddress = "127.0.0.1";
      port = 8082;
      serverContext = 32768;

      # The flake's llama.cpp predates support for the Inkling 2 Mini architecture.
      llamaCpp = pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "llama-cpp-inkling";
        version = "b12604";

        src = pkgs.fetchurl {
          url = "https://github.com/ggml-org/llama.cpp/releases/download/${finalAttrs.version}/llama-${finalAttrs.version}-bin-ubuntu-vulkan-x64.tar.gz";
          hash = "sha256-goEgywM07BFp7a92bnHi/rJa/mehbbWnXF+x+v3NQ2U=";
        };

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [
          pkgs.stdenv.cc.cc.lib
          pkgs.openssl
          pkgs.vulkan-loader
        ];

        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          runHook preInstall
          mkdir -p "$out/bin"
          cp -a llama-cli llama-server lib*.so* "$out/bin/"
          runHook postInstall
        '';
      });

      modelArgs = [
        "--hf-repo"
        "ggml-org/Inkling-2-Mini-GGUF:IQ4_NL"
        "--ubatch-size"
        "128"
        "--load-mode"
        "mmap"
        "--device"
        "Vulkan0"
        "--n-gpu-layers"
        "all"
        "--fit"
        "off"
      ];

      inkling = pkgs.writeShellApplication {
        name = model;
        text = ''
          exec ${llamaCpp}/bin/llama-cli ${lib.escapeShellArgs modelArgs} --ctx-size 4096 "$@"
        '';
      };

      inklingServer = pkgs.writeShellApplication {
        name = "${model}-server";
        text = ''
          exec ${llamaCpp}/bin/llama-server ${lib.escapeShellArgs modelArgs} \
            --host ${listenAddress} --port ${toString port} --alias ${model} \
            --ctx-size ${toString serverContext} --parallel 1 --jinja
        '';
      };
    in
    {
      networking.hostName = "armin-pc"; # Define your hostname.
      system.stateVersion = "24.11";

      home-manager.users.armin = {
        imports = [ hm."nixosConfigurations/armin-pc" ];
        programs.opencode.settings.providers.local-inkling = {
          name = "Local Inkling";
          package = "@opencode/ai/providers/openai-compatible";
          settings.baseURL = "http://${listenAddress}:${toString port}/v1";
          compatibility.reasoningField = "reasoning_content";
          models.${model} = {
            name = "Inkling 2 Mini";
            capabilities = {
              tools = true;
              input = [
                "text"
                "image"
              ];
              output = [ "text" ];
            };
            limit = {
              context = serverContext;
              output = 4096;
            };
          };
        };
      };

      environment.systemPackages = [
        inkling
        inklingServer
      ];
    };
}
