let
  variables = import ./../../../variables.nix;
  colors = variables.colors.active;
in
{
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
