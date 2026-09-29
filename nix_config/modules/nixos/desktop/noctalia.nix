{ ... }:
{
  flake.modules.nixos.noctalia = {
    # Noctalia desktop shell packages/services. The shell itself is started by
    # niri's spawn-at-startup.
    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    # Session/login greeter.
    services.displayManager.noctalia-greeter.enable = true;
  };
}
