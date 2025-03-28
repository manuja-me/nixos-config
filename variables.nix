let
  # Import centralized Gruvbox colors
  gruvboxColors = import ./themes/gruvbox.nix;
in
{
  "hostname": "nixos",
  "username": "manuja",
  "userShell": "zsh",
  "machineType": "laptop", # Can be "laptop", "desktop", or "vm"
  "packages": [
    "git",
    "vim",
    "htop",
    "xwayland",
    "wofi",
    "waybar",
    "swaylock",
    "swayidle",
    "wl-clipboard",
    "grim",
    "slurp",
    "mako",
    "yazi",
    "zsh",
    "oh-my-zsh",
    "jetbrains-mono-nerdfont", # Added Jetbrains Mono Nerd Font
    "xfce.thunar",
    "xfce.thunar-archive-plugin",
    "xfce.thunar-volman",
    "xfce.tumbler",
    "ffmpegthumbnailer",
    "gvfs",
    "thorium-browser" # Add Thorium Browser
  ],
  "swayConfig": {
    "modKey": "Mod4",
    "defaultWorkspace": "1",
    "xwayland": true,
    "launcher": "wofi",
    "statusBar": "waybar",
    "screenshot": "grim",
    "keybindings": {
      "toggleFullscreen": "Mod4+f",
      "killWindow": "Mod4+Shift+q",
      "launchMenu": "Mod4",
      "screenshot": "Mod4+Shift+s",
      "lockScreen": "Mod4+l",
      "terminal": "Mod4+Return",
      "browser": "Mod4+Shift+w",
      "fileManager": "Mod4+Shift+f",
      "terminalFileManager": "Mod4+e"
    },
    "fileManagers": {
      "terminal": "yazi",
      "gui": "thunar"
    }
  },
  "theme": {
    "name": "gruvbox-dark",
    "background": gruvboxColors.gruvbox.dark.background,
    "foreground": gruvboxColors.gruvbox.dark.foreground,
    "colors": {
      "primary": gruvboxColors.gruvbox.dark.primary.light,
      "secondary": gruvboxColors.gruvbox.dark.brightAccent.green,
      "accent": gruvboxColors.gruvbox.dark.brightAccent.pink
    },
    "borderRadius": 0,
    "font": {
      "family": "JetBrainsMono Nerd Font",
      "size": 12
    }
  },
  
  # Display settings
  "display": {
    "resolution": {
      "width": 1920,
      "height": 1080
    },
    "refreshRate": 144
  },

  # Make the whole colors object accessible
  "colors": {
    "active": gruvboxColors.gruvbox.dark
  },
  
  # Thorium browser configuration
  "thorium": {
    "defaultBrowser": true,       # Set as default browser
    "enableWideVine": false,      # DRM support (optional)
    "commandLineArgs": [
      "--enable-features=UseOzonePlatform",
      "--ozone-platform=wayland",
      "--enable-gpu-rasterization",
      "--enable-zero-copy"
    ]
  },
  
  # Boot configuration
  "boot": {
    "loader": "grub",     # Options: "grub" or "systemd-boot"
    "timeout": 5,
    "grub": {
      "useOSProber": true,
      "backgroundColor": "#282828",
      "fontSize": 16
    }
  },
  
  timezone = "Asia/Colombo"
}