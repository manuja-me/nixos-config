{ config, pkgs, lib, variables, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    
    config = rec {
      modifier = variables.swayConfig.modKey or "Mod4";
      
      # Terminal
      terminal = "alacritty";
      
      # Menu
      menu = "${variables.swayConfig.launcher or "wofi"} --show drun -i";
      
      # Output configuration
      output = {
        "*" = {
          bg = "~/.config/wallpaper.jpg fill";
        };
        # Add specific outputs as needed
      };
      
      # Input configuration
      input = {
        "*" = {
          xkb_layout = "us";
          xkb_options = "caps:swapescape";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };
      
      # Keybindings
      keybindings = lib.mkOptionDefault {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -b 'Yes' 'swaymsg exit'";
        "${modifier}+l" = "exec swaylock -f -c 282828";
        "${modifier}+Shift+s" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "${modifier}+Shift+f" = "exec ${variables.swayConfig.fileManagers.gui or "thunar"}";
        "${modifier}+e" = "exec ${terminal} -e ${variables.swayConfig.fileManagers.terminal or "yazi"}";
        # Use firefox as browser until thorium-browser is available
        "${modifier}+Shift+w" = "exec firefox";
      };
      
      # Floating windows criteria
      floating.criteria = [
        { app_id = "pavucontrol"; }
        { app_id = "blueberry.py"; }
        { window_role = "pop-up"; }
        { window_role = "bubble"; }
        { window_role = "dialog"; }
        { window_type = "dialog"; }
      ];
      
      # Gaps
      gaps = {
        inner = 10;
        outer = 5;
        smartGaps = true;
      };
      
      # Window decorations
      window = {
        border = 2;
        titlebar = false;
      };
      
      # Colors (Gruvbox theme)
      colors = let
        gruvbox = variables.colors.active or {};
        bg = gruvbox.background or "#282828";
        fg = gruvbox.foreground or "#ebdbb2";
        accent = gruvbox.primary.light or "#fe8019";
      in {
        focused = {
          background = bg;
          border = accent;
          childBorder = accent;
          indicator = accent;
          text = fg;
        };
        unfocused = {
          background = bg;
          border = bg;
          childBorder = bg;
          indicator = bg;
          text = fg;
        };
      };
      
      # Status bar
      bars = [{
        command = "${pkgs.waybar}/bin/waybar";
      }];
    };
    
    # Extra configuration
    extraConfig = ''
      # Additional Sway configuration
      for_window [app_id=".*"] opacity 0.95
      
      # Startup applications
      exec mako
      # Uncomment if autotiling is available:
      # exec_always ${pkgs.autotiling}/bin/autotiling
    '';
  };
}