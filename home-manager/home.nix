{ config, pkgs, variables, ... }:

{
  # Import program configurations
  imports = [
    ./programs/default.nix
    ./programs/zsh/default.nix  # Add explicit import for ZSH config
  ];

  home.packages = with pkgs; [
    # Other packages you might have
    thorium-browser
    xfce.thunar
    xfce.thunar-archive-plugin
    file # For file type detection
    shared-mime-info # For MIME type detection
  ];

  # Set default applications for file types
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "thorium-browser.desktop";
      "x-scheme-handler/http" = "thorium-browser.desktop";
      "x-scheme-handler/https" = "thorium-browser.desktop";
      "x-scheme-handler/about" = "thorium-browser.desktop";
      "x-scheme-handler/unknown" = "thorium-browser.desktop";
      # For terminal use Yazi (via script), for GUI use Thunar
      "inode/directory" = ["yazi-opener.desktop" "thunar.desktop"];
    };
  };

  # Create a desktop entry for Yazi to handle directory opening
  xdg.desktopEntries.yazi-opener = {
    name = "Yazi File Manager";
    genericName = "File Manager";
    exec = "alacritty -e yazi %u";
    terminal = false;
    categories = [ "Utility" "FileManager" ];
    mimeType = [ "inode/directory" ];
  };

  # Enhanced GTK theming
  gtk = {
    enable = true;
    theme = {
      name = variables.theme.name;
      package = pkgs.gruvbox-dark-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = 24;
    };
    font = {
      name = variables.theme.font.family;
      size = variables.theme.font.size;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-button-images = true;
      gtk-menu-images = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Qt theming to match GTK
  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Configure cursor
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 24;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
  };

  # Set keyboard options to swap Escape and Caps Lock
  home.keyboard = {
    options = [ "caps:swapescape" ];
  };

  # Enhanced session variables for theming
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    _JAVA_AWT_WM_NONREPARENTING = 1;
    XKB_DEFAULT_OPTIONS = "caps:swapescape";
    
    # GTK theme variables
    GTK_THEME = variables.theme.name;
    
    # Qt theme variables
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };

  # Configure Yazi file manager
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "modified";
        sort_reverse = true;
      };
      preview = {
        tab_size = 2;
        max_width = 1000;
        max_height = 1000;
      };
      opener = {
        text = ["nvim"];
      };
    };
    theme = {
      manager = {
        border_style = {
          fg = "${variables.colors.active.primary.light}";
          bg = "reset";
        };
        border_style_active = {
          fg = "${variables.colors.active.brightAccent.green}";
          bg = "reset";
        };
      };
      status = {
        separator_style = {
          fg = "${variables.colors.active.primary.light}";
          bg = "reset";
        };
      };
      selection = {
        fg = "${variables.colors.active.foreground}";
        bg = "${variables.colors.active.primary.light}";
      };
    };
  };

  # Configure notifications
  programs.mako = {
    enable = true;
    backgroundColor = "${variables.colors.active.background}";
    textColor = "${variables.colors.active.foreground}";
    borderColor = "${variables.colors.active.primary.light}";
    borderRadius = 0;
    borderSize = 2;
    defaultTimeout = 5000;
  };

  # Configure screen locking
  programs.swaylock = {
    enable = true;
    settings = {
      color = "${variables.colors.active.background}";
      "indicator-radius" = 100;
      "indicator-thickness" = 7;
      "inside-color" = "${variables.colors.active.background}";
      "inside-clear-color" = "${variables.colors.active.accent.yellow}";
      "inside-ver-color" = "${variables.colors.active.accent.blue}";
      "inside-wrong-color" = "${variables.colors.active.accent.red}";
      "key-hl-color" = "${variables.colors.active.brightAccent.green}";
      "line-color" = "${variables.colors.active.primary.light}";
      "ring-color" = "${variables.colors.active.primary.light}";
      "ring-clear-color" = "${variables.colors.active.accent.yellow}";
      "ring-ver-color" = "${variables.colors.active.accent.blue}";
      "ring-wrong-color" = "${variables.colors.active.accent.red}";
      "separator-color" = "${variables.colors.active.background}";
      "text-color" = "${variables.colors.active.foreground}";
    };
  };

  # Configure wofi application launcher
  programs.wofi = {
    enable = true;
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 12pt;
      }
      window {
        margin: 5px;
        border: 2px solid ${variables.colors.active.primary.light};
        background-color: ${variables.colors.active.background};
        border-radius: 0px;
      }
      #input {
        margin: 5px;
        border: 2px solid ${variables.colors.active.primary.light};
        background-color: ${variables.colors.active.primary.dark};
        color: ${variables.colors.active.foreground};
      }
      #outer-box {
        margin: 20px;
        background-color: ${variables.colors.active.background};
        color: ${variables.colors.active.foreground};
      }
      #entry:selected {
        background-color: ${variables.colors.active.primary.light};
        color: ${variables.colors.active.brightAccent.green};
      }
    '';
    settings = {
      show = "drun";
      width = 500;
      height = 300;
      always_parse_args = true;
      show_all = true;
      print_command = true;
      layer = "overlay";
      insensitive = true;
    };
  };

  # Configure Thunar
  xdg.configFile."Thunar/uca.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <actions>
      <action>
        <icon>utilities-terminal</icon>
        <name>Open Terminal Here</name>
        <command>alacritty --working-directory %f</command>
        <description>Open Terminal in Current Directory</description>
        <patterns>*</patterns>
        <directories/>
      </action>
      <action>
        <icon>edit-find-replace</icon>
        <name>Open in Neovim</name>
        <command>alacritty -e nvim %f</command>
        <description>Edit with Neovim</description>
        <patterns>*</patterns>
        <text-files/>
      </action>
    </actions>
  '';

  # Make scripts executable and add them to path
  home.file = {
    ".local/bin/battery-monitor" = {
      source = ./scripts/battery-monitor.sh;
      executable = true;
    };
    ".local/bin/system-update" = {
      source = ./scripts/system-update.sh;
      executable = true;
    };
    ".local/bin/volume-control" = {
      source = ./scripts/volume.sh;
      executable = true;
    };
    ".local/bin/brightness-control" = {
      source = ./scripts/brightness.sh;
      executable = true;
    };
    ".local/bin/network-monitor" = {
      source = ./scripts/network-monitor.sh;
      executable = true;
    };
    ".local/bin/network-speed" = {
      source = ./scripts/network-speed.sh;
      executable = true;
    };
  };

  # Ensure scripts are in PATH
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Start the battery monitor service
  systemd.user.services.battery-monitor = {
    Unit = {
      Description = "Battery monitor service";
      After = "graphical-session-pre.target";
      PartOf = "graphical-session.target";
    };
    Service = {
      ExecStart = "${config.home.homeDirectory}/.local/bin/battery-monitor";
      Restart = "always";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Start the network monitor service
  systemd.user.services.network-monitor = {
    Unit = {
      Description = "Network monitor service";
      After = "graphical-session-pre.target";
      PartOf = "graphical-session.target";
    };
    Service = {
      ExecStart = "${config.home.homeDirectory}/.local/bin/network-monitor";
      Restart = "always";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Start the network speed monitor service for waybar
  systemd.user.services.network-speed-monitor = {
    Unit = {
      Description = "Network speed monitor for waybar";
      After = "graphical-session-pre.target";
      PartOf = "graphical-session.target";
    };
    Service = {
      ExecStart = "${config.home.homeDirectory}/.local/bin/network-speed";
      Restart = "always";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Add improved aliases for system updates
  programs.zsh.shellAliases = {
    # ...existing code...
    
    # System update aliases with notifications
    nrb = "system-update switch";
    nrbb = "system-update boot";
    hms = "system-update home";
    nixupgrade = "system-update full";
    nixupgrade-reboot = "system-update full reboot";
  };
}
