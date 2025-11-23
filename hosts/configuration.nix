{ config, pkgs, lib, inputs, ... }: 

let
  variables = import ./../variables.nix;
in
{
  imports = [
    # Import machine-specific configuration based on system type
    (if builtins.pathExists /etc/nixos/machine-type
     then
       let 
         machineType = builtins.readFile /etc/nixos/machine-type;
       in
         if machineType == "laptop" then ./machine-specific/laptop.nix
         else if machineType == "desktop" then ./machine-specific/desktop.nix
         else if machineType == "vm" then ./machine-specific/vm.nix
         else ./machine-specific/laptop.nix  # Default to laptop if unknown
     else ./machine-specific/laptop.nix)  # Default to laptop if file doesn't exist
  ];

  # Basic system settings 
  networking.hostName = variables.hostname; # Using the hostname from variables
  networking.networkmanager.enable = true; 

  # Time settings 
  time.timeZone = variables.timezone or "America/New_York"; 

  # Package management 
  environment.systemPackages = with pkgs; [ 
    vim 
    git 
    firefox 

    # Theming packages
    gruvbox-dark-gtk
    papirus-icon-theme
    adwaita-qt
    gnome.adwaita-icon-theme
    qt5.qtwayland
    qt6.qtwayland
    libsForQt5.qtstyleplugins

    # Thunar and related packages
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.tumbler # For thumbnails
    ffmpegthumbnailer # For video thumbnails
    gvfs # For trash, mtp, etc.

    # Tools for scripts
    pamixer           # Volume control
    brightnessctl     # Brightness control
    libnotify         # For notify-send
    acpi              # For battery information

    # Network monitoring tools
    iw
    wireless-tools
    bc
    jq
  ]; 

  # Enable services 
  services.openssh.enable = true; 
  services.nginx.enable = true; 

  # Enable Thunar services
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support

  # Set zsh as default shell system-wide
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
    };
  };

  # Make zsh the default shell
  users.defaultUserShell = pkgs.zsh;

  # User configuration with zsh as shell
  users.users.${variables.username} = { # Using the username from variables
    isNormalUser = true; 
    extraGroups = [ "wheel" "networkmanager" ]; 
    shell = pkgs.zsh;
  }; 

  # Allow unfree packages system-wide
  nixpkgs.config.allowUnfree = true;
  
  # Enable 32-bit support for system packages
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;  # Support for 32-bit applications (like Steam)
  };
  
  # Additional 32-bit compatibility packages
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [
    libva
    vaapiIntel
    vaapiVdpau
    libvdpau
  ];

  # System fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    noto-fonts
    noto-fonts-emoji
  ];

  # Default font configuration
  fonts.fontconfig = {
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };

  # Configure keyboard to swap Escape and Caps Lock
  services.xserver.xkbOptions = "caps:swapescape";
  
  # Ensure this setting also applies to console
  console.useXkbConfig = true;
  
  # Apply the same configuration to Wayland via libinput
  services.xserver.libinput.enable = true;

  # For Sway/Wayland specific configuration
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraOptions = [];
    extraSessionCommands = ''
      # Apply keyboard remapping in Wayland
      export XKB_DEFAULT_OPTIONS=caps:swapescape
    '';
  };

  # System-wide GTK and Qt theme configuration
  environment.variables = {
    # GTK theme variables
    GTK_THEME = variables.theme.name;
    
    # Qt theme variables
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };

  # Allow users to control brightness without sudo
  hardware.brillo.enable = true;
  users.groups.video.members = [ variables.username ];
  services.acpid.enable = true;

  # Ensure services for power management are started
  services.upower.enable = true;
  powerManagement.enable = true;

  # Enable Thorium browser (when available)
  # NOTE: thorium-browser is not currently available in the flake inputs
  # Uncomment when thorium-browser flake is added:
  # programs.thorium-browser = {
  #   enable = true;
  #   defaultBrowser = variables.thorium.defaultBrowser or true;
  #   commandLineArgs = variables.thorium.commandLineArgs or [
  #     "--enable-features=UseOzonePlatform"
  #     "--ozone-platform=wayland"
  #     "--enable-gpu-rasterization"
  #     "--enable-zero-copy"
  #   ];
  #   enableWideVine = variables.thorium.enableWideVine or false;
  # };

  # Wayland support for Thorium and other browsers
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # System options 
  system.stateVersion = "22.05"; 

  # Boot configuration using GRUB
  boot = {
    loader = {
      # Use GRUB bootloader
      grub = {
        enable = true;
        device = "nodev";    # Install GRUB to the ESP partition
        efiSupport = true;   # Enable EFI support
        useOSProber = true;  # Auto-detect other operating systems
        theme = null;        # No theme by default
        fontSize = 16;       # Increase font size for better readability
        configurationLimit = 10;  # Limit the number of configurations
        # Apply Gruvbox-like colors
        splashImage = null;
        backgroundColor = "#282828";  # Dark background
      };
      
      # General EFI settings
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";  # Default EFI mount point
      };
      
      # Disable systemd-boot
      systemd-boot.enable = false;
    };
    
    # Timeout in seconds for menu display
    loader.timeout = 5;
  };

  # Ensure Plymouth is disabled (often used with systemd-boot)
  boot.plymouth.enable = false;
}