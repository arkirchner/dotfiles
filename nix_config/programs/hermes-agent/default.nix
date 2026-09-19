{ config, pkgs, lib, ... }:

{
  # Secrets are managed by sops-nix (Home Manager module). The file
  # nix_config/secrets/hermes.yaml is encrypted to the card-backed GPG key
  # 548677257695BF67E731CA87D7E73A3B55E27CC2 (YubiKey), so decryption needs
  # the card and its PIN at every activation and login.
  sops = {
    gnupg.home = "${config.home.homeDirectory}/.gnupg";
    defaultSopsFile = ../../secrets/hermes.yaml;
    secrets."hermes-env" = { };
  };

  services.hermes-agent = {
    enable = true;

    # No messaging platform (Telegram/Discord/Slack) in the first milestone.
    # Only services.hermes-agent.backend runs: the local dashboard.
    gateway.enable = false;

    settings = {
      # HPI internal AI service (OpenAI-compatible, Bearer auth). Endpoint and
      # model mirror nix_config/programs/opencode/default.nix. Other available
      # models: HPI-Intern-Qwen3.6-35B-A3B, HPI-Intern-Qwen35-122B-A10B.
      # Keep provider/model config isolated here so it can later point at
      # Ollama, vLLM, or a Kubernetes service without touching anything else.
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

    environmentFiles = [ config.sops.secrets."hermes-env".path ];
  };

  # sops-nix installs the secret through a systemd user service, while Home
  # Manager's activation merges environmentFiles into $HERMES_HOME/.env. Those
  # two steps are unordered, so .env can keep a stale value after the secret
  # changes. Refresh .env from the decrypted sops secret right before the
  # backend starts, and start only after sops-nix has installed it.
  systemd.user.services.hermes-backend = {
    Unit.After = [ "sops-nix.service" ];
    Unit.Wants = [ "sops-nix.service" ];
    Service.ExecStartPre = [
      "${pkgs.writeShellScript "hermes-env-refresh" ''
        set -euo pipefail
        umask 077
        install -m 0600 ${config.sops.secrets."hermes-env".path} ${config.home.homeDirectory}/.hermes/.env
      ''}"
    ];
  };

  # `hermes` on PATH, sharing state with the service via HERMES_HOME.
  programs.hermes-agent.enable = true;
}
