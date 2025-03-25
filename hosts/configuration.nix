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
  time.timeZone = "America/New_York"; 

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
  fonts.fonts = with pkgs; [
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

  # System options 
  system.stateVersion = "22.05"; 

  # Add the thorium-browser overlay
  nixpkgs.overlays = [
    inputs.thorium-browser.overlays.default
    // ...existing overlays...
  ];
}