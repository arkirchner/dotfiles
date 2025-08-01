{config, pkgs, ... }: 
{

  home.packages = with pkgs; [
    hyprland
    playerctl
    brightnessctl
    firefox
    kitty
    pwvucontrol
    grim
    slurp
  ];

  programs.hyprlock.enable = true;

  services.mako.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;

    extraConfig = ''
      ################
      ### MONITORS ###
      ################
      
      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor=eDP-1,1920x1080,1200x1560,1
      monitor=DP-4,1920x1200,0x0,1,transform,1
      monitor=DP-3,1920x1200,1200x360,1
      
      
      ###################
      ### MY PROGRAMS ###
      ###################
      
      # See https://wiki.hyprland.org/Configuring/Keywords/
      
      # Set programs that you use
      $terminal = kitty
      $fileManager = thunar
      $menu = wofi --show drun
      $browser = firefox
      
      
      #################
      ### AUTOSTART ###
      #################
      
      # Autostart necessary processes (like notifications daemons, status bars, etc.)
      # Or execute your favorite apps at launch like this:
      
      # exec-once = $terminal
      # exec-once = nm-applet &
      # exec-once = waybar & hyprpaper & firefox
      exec-once = waybar & mako
      
      
      #############################
      ### ENVIRONMENT VARIABLES ###
      #############################
      
      # See https://wiki.hyprland.org/Configuring/Environment-variables/
      
      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24
      
      
      #####################
      ### LOOK AND FEEL ###
      #####################
      
      # Refer to https://wiki.hyprland.org/Configuring/Variables/
      
      # https://wiki.hyprland.org/Configuring/Variables/#general
      general { 
          gaps_in = 1
          gaps_out = 2
      
          border_size = 2
      
          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)
      
          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = false 
      
          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = false
      
          layout = dwindle
      }
      
      # https://wiki.hyprland.org/Configuring/Variables/#decoration
      decoration {
          rounding = 1
      
          # Change transparency of focused and unfocused windows
          active_opacity = 1.0
          inactive_opacity = 1.0
      
          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur {
              enabled = true
              size = 3
              passes = 1
              
              vibrancy = 0.1696
          }
      }
      
      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations {
          enabled = true
      
          # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
      
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
      
          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }
      
      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      dwindle {
          pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true # You probably want this
      }
      
      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      master {
          new_status = master
      }
      
      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc { 
          disable_hyprland_logo = true
      }
      
      
      #############
      ### INPUT ###
      #############
      
      # https://wiki.hyprland.org/Configuring/Variables/#input
      input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options =
          kb_rules =
      
          follow_mouse = 1
      
          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      
          touchpad {
              natural_scroll = false
          }
      }
      
      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      gestures {
          workspace_swipe = false
      }
      
      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
      device {
          name = epic-mouse-v1
          sensitivity = -0.5
      }
      
      
      ####################
      ### KEYBINDINGSS ###
      ####################
      
      # See https://wiki.hyprland.org/Configuring/Keywords/
      $mainMod = SUPER # Sets "Windows" key as main modifier
      
      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mainMod, Q, exec, $terminal
      bind = $mainMod, C, killactive,
      bind = $mainMod, M, exit,
      bind = $mainMod, E, exec, $fileManager
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, R, exec, $menu
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, J, togglesplit, # dwindle
      bind = $mainMod, W, exec, $browser
      bind = $mainMod, L, exec, hyprlock
      bind = $mainMod, S, exec, sh -c 'mkdir -p ~/Pictures/screenshot && grim -g "$(slurp)" ~/Pictures/screenshot/$(date +%s).png'
      
      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d
      
      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10
      
      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10
      
      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1
      
      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Function keys
      bind = ,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bind = ,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bind = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind = ,XF86AudioPlay, exec, playerctl play-pause
      bind = ,XF86AudioPause, exec, playerctl play-pause
      bind = ,XF86AudioNext, exec, playerctl next
      bind = ,XF86AudioPrev, exec, playerctl previous
      bind = ,XF86MonBrightnessDown,exec,brightnessctl set 5%-
      bind = ,XF86MonBrightnessUp,exec,brightnessctl set +5%

      ##############################
      ### WINDOWS AND WORKSPACES ###
      ##############################
      
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules
      
      # Example windowrule v1
      # windowrule = float, ^(kitty)$
      
      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      
      windowrulev2 = suppressevent maximize, class:.* # You'll probably like this.
    '';
  };
}
