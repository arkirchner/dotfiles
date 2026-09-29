{ ... }:
{
  flake.modules.homeManager.niri =
    { pkgs, ... }:
    {
      # Base clipboard utility for CLI apps; Noctalia owns the clipboard
      # history panel itself.
      home.packages = with pkgs; [
        wl-clipboard
      ];

      wayland.windowManager.niri = {
        enable = true;

        settings = {
          _children = [
            # Noctalia desktop shell: bar, launcher, notifications, lock, idle,
            # wallpaper, clipboard and screenshots.
            { spawn-at-startup._args = [ "noctalia" "--daemon" ]; }

            # MONITORS
            {
              output = {
                _args = [ "eDP-1" ];
                mode = "1920x1080";
                position._props = {
                  x = 1200;
                  y = 1560;
                };
              };
            }
            {
              output = {
                _args = [ "DP-4" ];
                mode = "1920x1200";
                transform = "90";
                position._props = {
                  x = 0;
                  y = 0;
                };
              };
            }
            {
              output = {
                _args = [ "DP-3" ];
                mode = "1920x1200";
                position._props = {
                  x = 1200;
                  y = 360;
                };
              };
            }

            # Noctalia settings window floats (upstream recommendation)
            {
              window-rule = {
                match._props = { app-id = "^dev\\.noctalia\\.Noctalia$"; };
                open-floating = true;
                default-column-width = { fixed = 1080; };
                default-window-height = { fixed = 920; };
              };
            }
            # Shows Noctalia's blurred wallpaper backdrop in niri's overview.
            {
              layer-rule = {
                match._props = { namespace = "^noctalia-backdrop"; };
                place-within-backdrop = true;
              };
            }
          ];

          layout = {
            gaps = 2;
            focus-ring = {
              width = 2;
              active-color = "#33ccff";
              inactive-color = "#595959";
            };
          };

          input = {
            keyboard.xkb.layout = "us";
            touchpad.tap = { };
            focus-follows-mouse = { };
          };

          # Noctalia owns the launcher, control center, settings, lock,
          # clipboard, screenshots and the volume/brightness/media OSDs.
          binds = {
            "Mod+Q" = { spawn = [ "kitty" ]; };
            "Mod+C" = { close-window = { }; };
            "Mod+M" = { quit = { }; };
            "Mod+E" = { spawn = [ "kitty" "-e" "yazi" ]; };
            "Mod+W" = { spawn = [ "firefox" ]; };
            "Mod+V" = { spawn = [ "noctalia" "msg" "panel-toggle" "clipboard" ]; };
            "Mod+L" = { spawn = [ "noctalia" "msg" "session" "lock" ]; };
            "Mod+Space" = { spawn = [ "noctalia" "msg" "panel-toggle" "launcher" ]; };
            "Mod+S" = { spawn = [ "noctalia" "msg" "panel-toggle" "control-center" ]; };
            "Mod+Comma" = { spawn = [ "noctalia" "msg" "settings-toggle" ]; };
            "Print" = { spawn = [ "noctalia" "msg" "screenshot-region" ]; };

            "Mod+Left" = { focus-column-left = { }; };
            "Mod+Right" = { focus-column-right = { }; };
            "Mod+Up" = { focus-window-up = { }; };
            "Mod+Down" = { focus-window-down = { }; };

            "Mod+1" = { focus-workspace = 1; };
            "Mod+2" = { focus-workspace = 2; };
            "Mod+3" = { focus-workspace = 3; };
            "Mod+4" = { focus-workspace = 4; };
            "Mod+5" = { focus-workspace = 5; };
            "Mod+6" = { focus-workspace = 6; };
            "Mod+7" = { focus-workspace = 7; };
            "Mod+8" = { focus-workspace = 8; };
            "Mod+9" = { focus-workspace = 9; };
            "Mod+0" = { focus-workspace = 10; };

            "Mod+Shift+1" = { move-column-to-workspace = 1; };
            "Mod+Shift+2" = { move-column-to-workspace = 2; };
            "Mod+Shift+3" = { move-column-to-workspace = 3; };
            "Mod+Shift+4" = { move-column-to-workspace = 4; };
            "Mod+Shift+5" = { move-column-to-workspace = 5; };
            "Mod+Shift+6" = { move-column-to-workspace = 6; };
            "Mod+Shift+7" = { move-column-to-workspace = 7; };
            "Mod+Shift+8" = { move-column-to-workspace = 8; };
            "Mod+Shift+9" = { move-column-to-workspace = 9; };
            "Mod+Shift+0" = { move-column-to-workspace = 10; };

            "Mod+WheelScrollDown" = {
              _props.cooldown-ms = 150;
              focus-workspace-down = { };
            };
            "Mod+WheelScrollUp" = {
              _props.cooldown-ms = 150;
              focus-workspace-up = { };
            };

            "XF86AudioRaiseVolume" = {
              _props.allow-when-locked = true;
              spawn = [ "noctalia" "msg" "volume-up" ];
            };
            "XF86AudioLowerVolume" = {
              _props.allow-when-locked = true;
              spawn = [ "noctalia" "msg" "volume-down" ];
            };
            "XF86AudioMute" = {
              _props.allow-when-locked = true;
              spawn = [ "noctalia" "msg" "volume-mute" ];
            };
            "XF86AudioPlay" = {
              _props.allow-when-locked = true;
              spawn = [ "noctalia" "msg" "media" "toggle" ];
            };
            "XF86AudioPause" = {
              _props.allow-when-locked = true;
              spawn = [ "noctalia" "msg" "media" "toggle" ];
            };
            "XF86AudioNext" = {
              _props.allow-when-locked = true;
              spawn = [ "noctalia" "msg" "media" "next" ];
            };
            "XF86AudioPrev" = {
              _props.allow-when-locked = true;
              spawn = [ "noctalia" "msg" "media" "previous" ];
            };
            "XF86MonBrightnessDown" = {
              _props.allow-when-locked = true;
              spawn = [ "noctalia" "msg" "brightness-down" ];
            };
            "XF86MonBrightnessUp" = {
              _props.allow-when-locked = true;
              spawn = [ "noctalia" "msg" "brightness-up" ];
            };
          };

          # Lets Noctalia activate windows / run notification actions.
          debug.honor-xdg-activation-with-invalid-serial = { };
        };
      };
    };
}
