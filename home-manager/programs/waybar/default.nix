let
  variables = import ./../../../variables.nix;
  colors = variables.colors.active;
in
{
  programs.waybar = {
    enable = true;
    style = ''
      * {
        border: none;
        border-radius: 0;  /* Ensure square corners */
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 5 Free";
        font-size: 12pt;
        min-height: 0;
      }

      window#waybar {
        background: ${colors.background};
        color: ${colors.foreground};
        border-bottom: 3px solid ${colors.primary.light};
      }

      #workspaces button {
        padding: 0 5px;
        background: transparent;
        color: ${colors.foreground};
        border-bottom: 3px solid transparent;
        border-radius: 0;  /* Ensure square corners */
      }

      #workspaces button.focused {
        background: ${colors.primary.light};
        border-bottom: 3px solid ${colors.brightAccent.green};
        border-radius: 0;  /* Ensure square corners */
      }

      #workspaces button.urgent {
        background: ${colors.accent.red};
        border-radius: 0;  /* Ensure square corners */
      }

      #mode, #clock, #battery, #cpu, #memory, #network, #network-speed, #pulseaudio, #custom-spotify, #tray, #idle_inhibitor {
        padding: 0 10px;
        margin: 0 5px;
        border-radius: 0;  /* Ensure square corners */
      }

      #network-speed {
        color: ${colors.brightAccent.blue};
        border-bottom: 3px solid ${colors.accent.blue};
      }

      #network-speed.up {
        color: ${colors.brightAccent.green};
        border-bottom: 3px solid ${colors.accent.green};
      }

      #network-speed.down {
        color: ${colors.brightAccent.yellow};
        border-bottom: 3px solid ${colors.accent.yellow};
      }

      #battery.charging {
        color: ${colors.brightAccent.green};
      }

      #battery.warning:not(.charging) {
        background: ${colors.brightAccent.yellow};
        color: ${colors.background};
        border-bottom: 3px solid ${colors.brightAccent.yellow};
        border-radius: 0;  /* Ensure square corners */
      }

      #battery.critical:not(.charging) {
        background: ${colors.brightAccent.red};
        color: ${colors.background};
        border-bottom: 3px solid ${colors.brightAccent.red};
        border-radius: 0;  /* Ensure square corners */
      }

      #network.disconnected {
        background: ${colors.brightAccent.red};
        border-radius: 0;  /* Ensure square corners */
      }

      #pulseaudio.muted {
        background: ${colors.accent.yellow};
        color: ${colors.background};
        border-radius: 0;  /* Ensure square corners */
      }
    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = ["sway/workspaces" "sway/mode"];
        modules-center = ["sway/window"];
        modules-right = ["network-speed" "pulseaudio" "network" "cpu" "memory" "battery" "clock" "tray"];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };

        "sway/window" = {
          max-length = 50;
        };

        tray = {
          spacing = 10;
        };

        clock = {
          format = "{:%a, %d %b %Y %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
        };

        cpu = {
          format = "CPU {usage}%";
          tooltip = false;
        };

        memory = {
          format = "MEM {}%";
        };

        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "BAT {capacity}%";
          format-charging = "CHG {capacity}%";
          format-plugged = "FULL {capacity}%";
          format-alt = "{time}";
          format-good = "BAT {capacity}%";
          format-full = "FULL {capacity}%";
        };

        network = {
          format-wifi = "WIFI {essid}";
          format-ethernet = "ETH {ifname}";
          format-linked = "ETH {ifname} (No IP)";
          format-disconnected = "Disconnected";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };

        "network-speed" = {
          interface = "wlan0,eth0,enp*,wlp*"; # Automatically detect interface
          interval = 1; # Update every second
          min-length = 15;
          format = "▼ {bandwidthDownBytes} ▲ {bandwidthUpBytes}";
          format-disconnected = "No network";
          tooltip-format = "Download: {bandwidthDownBits}\nUpload: {bandwidthUpBits}";
        };

        pulseaudio = {
          format = "VOL {volume}%";
          format-bluetooth = "BT {volume}%";
          format-bluetooth-muted = "BT MUTED";
          format-muted = "MUTED";
          format-source = "MIC {volume}%";
          format-source-muted = "MIC MUTED";
          on-click = "pavucontrol";
        };
      };
    };
  };

  # Configure Alacritty as the default terminal emulator
  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color";
      };
      
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "full";
        opacity = 0.95;
        dynamic_title = true;
      };
      
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        size = 12.0;
      };
      
      # Gruvbox dark theme to match Neovim theme
      colors = {
        primary = {
          background = "${colors.background}";
          foreground = "${colors.foreground}";
        };
        normal = {
          black = "${colors.background}";
          red = "${colors.accent.red}";
          green = "${colors.accent.green}";
          yellow = "${colors.accent.yellow}";
          blue = "${colors.accent.blue}";
          magenta = "${colors.accent.pink}";
          cyan = "${colors.accent.cyan}";
          white = "${colors.primary.light}";
        };
        bright = {
          black = "#928374";
          red = "${colors.brightAccent.red}";
          green = "${colors.brightAccent.green}";
          yellow = "${colors.brightAccent.yellow}";
          blue = "${colors.brightAccent.blue}";
          magenta = "${colors.brightAccent.pink}";
          cyan = "${colors.brightAccent.cyan}";
          white = "${colors.foreground}";
        };
      };
      
      cursor = {
        style = "Block";
        unfocused_hollow = true;
      };
      
      shell = {
        program = "${pkgs.bash}/bin/bash";
      };
    };
  };

  # Set Alacritty as the default terminal for applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/terminal" = "alacritty.desktop";
    };
  };
}
