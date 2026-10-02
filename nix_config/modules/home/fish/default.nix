{ ... }:
{
  flake.modules.homeManager.fish =
    { lib, pkgs, ... }:
    let
      tatConfig = builtins.readFile ./stay_always_in_tmux;
    in
    {
      home.shellAliases = {
        gs = "git status ";
        ga = "git add ";
        gb = "git branch --sort=-committerdate ";
        gc = "git commit";
        gd = "git diff";
        go = "git checkout ";
        gk = "gitk --all&";
        gx = "gitx --all";
        hpi-vpn = "sudo snx-rs -o vpn -s vpn.hpi.de";
        nixos-update = "sudo nixos-rebuild switch";
      };

      programs = {
        direnv = {
          enable = true;
          silent = true;
          nix-direnv.enable = true;
          enableFishIntegration = true;
          # Home Manager writes this to ~/.config/direnv/direnvrc, which direnv
          # sources before it evaluates any .envrc, so `use devenv` is available
          # in every project and each .envrc needs no preamble.
          #
          # eval, not `source "$(...)"`: that form fails under bash 5.3 with
          # "File name too long" rather than sourcing the string as a script.
          stdlib = ''
            eval "$(${lib.getExe pkgs.devenv} direnvrc)"
          '';
        };

        carapace = {
          enable = true;
          enableFishIntegration = true;
        };

        fish = {
          enable = true;
          interactiveShellInit = ''
            set -g fish_greeting
            set -g fish_color_normal cdd6f4
            set -g fish_color_command 89b4fa
            set -g fish_color_param f2cdcd
            set -g fish_color_keyword cba6f7
            set -g fish_color_quote a6e3a1
            set -g fish_color_redirection f5c2e7
            set -g fish_color_end fab387
            set -g fish_color_comment 7f849c
            set -g fish_color_error f38ba8
            set -g fish_color_gray 6c7086
            set -g fish_color_selection --background=313244
            set -g fish_color_search_match --background=313244
            set -g fish_color_option a6e3a1
            set -g fish_color_operator f5c2e7
            set -g fish_color_escape eba0ac
            set -g fish_color_autosuggestion 6c7086
            set -g fish_color_cancel f38ba8
            set -g fish_color_cwd f9e2af
            set -g fish_color_user 94e2d5
            set -g fish_color_host 89b4fa
            set -g fish_color_host_remote a6e3a1
            set -g fish_color_status f38ba8
            set -g fish_pager_color_progress 6c7086
            set -g fish_pager_color_prefix f5c2e7
            set -g fish_pager_color_completion cdd6f4
            set -g fish_pager_color_description 6c7086
            ${tatConfig}

            # devenv's direnvrc exports DEVENV_CMDLINE, which holds the
            # `--from ...` the current project's .envrc passed to `use devenv`.
            # Repeating it here means these work without naming the app, and
            # work in all four xikolo directories at once.
            function devenv-up
                command devenv up -d $DEVENV_CMDLINE
            end

            function devenv-down
                command devenv down $DEVENV_CMDLINE
            end
          '';
        };
      };
    };
}
