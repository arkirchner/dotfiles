{ ... }:
{
  flake.modules.homeManager.hermes-agent =
    { config, ... }:
    {
      services.hermes-agent = {
        enable = true;

        # No messaging platform (Telegram/Discord/Slack) in the first milestone.
        # Only services.hermes-agent.backend runs: the local dashboard.
        gateway.enable = false;

        settings = {
          # HPI internal AI service (OpenAI-compatible, Bearer auth). Endpoint
          # and model mirror nix_config/modules/home/opencode/default.nix. Other
          # available models: HPI-Intern-Qwen3.6-35B-A3B,
          # HPI-Intern-Qwen35-122B-A10B. Keep provider/model config isolated
          # here so it can later point at Ollama, vLLM, or a Kubernetes service
          # without touching anything else.
          #
          # HPI_API_KEY itself is not managed here: the backend reads it from
          # its environment, so it has to be in the user manager's environment
          # (for example ~/.config/environment.d/hpi.conf).
          model = {
            provider = "custom";
            base_url = "https://101010.hpi.de/api/v1";
            default = "HPI-Intern-Qwen38-27B";
            key_env = "HPI_API_KEY";
          };
          terminal.backend = "local";
        };

        # Local dashboard only. Bound to loopback; never exposed to the LAN.
        backend.mode = "dashboard";
        backend.host = "127.0.0.1";
        backend.port = 9119;

        # Dedicated workspace so the agent's file tools do not default to $HOME.
        workingDirectory = "${config.home.homeDirectory}/.hermes/workspace";
      };

      # `hermes` on PATH, sharing state with the service via HERMES_HOME.
      programs.hermes-agent.enable = true;
    };
}
