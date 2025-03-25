{
  "home-manager": {
    "programs": {
      "sway": {
        "default.nix": {
          "config": {
            "sway": {
              "xwayland": true,
              "output": {
                "eDP-1": {
                  "scale": 1.0,
                  "transform": "normal",
                  "bg": "/path/to/your/wallpaper.jpg fill"
                }
              },
              "input": {
                "*": {
                  "xkb_layout": "us",
                  "tap": "enabled",
                  "natural_scroll": "enabled"
                }
              },
              "workspace": [
                {
                  "name": "1",
                  "layout": "tabbed"
                },
                {
                  "name": "2",
                  "layout": "stacked"
                }
              ],
              "keybindings": {
                "mod": "Mod4",
                "bindings": {
                  "Mod4+Return": "exec alacritty",
                  "Mod4+d": "exec wofi --show drun -i",
                  "Mod4+Shift+e": "exec killall sway",
                  "Mod4+l": "exec swaylock -f -c 282828",
                  "Mod4+Shift+s": "exec grim -g \"$(slurp)\" - | wl-copy"
                }
              },
              "floating": {
                "enable": true,
                "criteria": [
                  { "app_id": "pavucontrol" },
                  { "app_id": "blueberry.py" },
                  { "window_role": "pop-up" },
                  { "window_role": "bubble" },
                  { "window_role": "dialog" },
                  { "window_type": "dialog" }
                ]
              },
              "gaps": {
                "inner": 10,
                "outer": 5,
                "smart": true
              },
              "bars": [
                {
                  "command": "waybar"
                }
              ]
            }
          }
        }
      }
    }
  }
}