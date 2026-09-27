{ ... }:
{
  flake.modules.homeManager.wofi =
    { ... }:
    {
      programs.wofi = {
        enable = true;

        style = builtins.readFile ./wofi.css;
      };
    };
}
