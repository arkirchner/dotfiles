{ ... }:
{
  flake.modules.homeManager.fish =
    { ... }:
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
          # devenv's `use devenv` is deliberately NOT preloaded here. devenv's
          # direnvrc redefines two functions that nix-direnv's home-manager
          # integration also defines (_nix_direnv_preflight, _nix_import_env)
          # with different semantics, and whichever loads last wins for every
          # directory. Preloading devenv's broke `use flake`: nix-direnv's
          # preflight never ran, so its `_nix` helper expanded to nothing
          # ("--no-warn-dirty: command not found"), and nix-direnv passes
          # _nix_import_env a profile path where devenv's expects env text
          # ("flake-profile-...rc: No such file or directory").
          #
          # devenv projects instead follow devenv's canonical .envrc: an
          # `eval "$(devenv direnvrc)"` right before `use devenv`, so devenv's
          # definitions only exist where nix-direnv isn't in use.
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
            # work in every xikolo directory at once.
            #
            # eval, not a bare $DEVENV_CMDLINE: fish never word-splits an
            # unquoted variable, unlike bash, so passing it directly hands
            # devenv the whole string as a single argument and it rejects it as
            # an unexpected argument. eval re-parses it into separate ones.
            # Empty stays empty, so a project that ran a plain `use devenv`
            # still works.
            function devenv-up
                eval command devenv up -d $DEVENV_CMDLINE
            end

            function devenv-down
                eval command devenv down $DEVENV_CMDLINE
            end
          '';
        };
      };
    };
}
