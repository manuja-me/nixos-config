{ config, pkgs, lib, ... }:

{
  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    # Core packages
    firefox
    chromium
    neovim
    git
    
    # Desktop environment enhancements
    xwayland
    wofi
    waybar
    swaylock
    swayidle
    wl-clipboard
    grim
    slurp
    mako
    swaybg
    
    # Media and productivity
    mpv
    vlc
    libreoffice
    gimp
    
    # Development
    vscode
    docker
    
    # System utilities
    htop
    btop
    ncdu
    ripgrep
    fd
    
    # Hardware acceleration packages
    libva
    libva-utils
    vaapiVdpau
    libvdpau
    intel-media-driver # For Intel GPUs
    nvidia-vaapi-driver # For NVIDIA GPUs
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Hardware configuration
  hardware = {
    enableAllFirmware = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for some applications)
        vaapiVdpau
        libvdpau
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vaapiIntel
        vaapiVdpau
        libvdpau
      ];
    };
    pulseaudio.enable = true;
  };
  
  # Optional: Set environment variables for hardware acceleration
  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD"; # Use "nvidia" for NVIDIA GPUs
    VDPAU_DRIVER = "va_gl"; # Use "nvidia" for NVIDIA GPUs
  };

  # X11 and Wayland configuration
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    videoDrivers = [ "nvidia" ]; # Change according to your GPU
  };

  # Sway specific configurations
  services.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      xwayland
      wofi
      waybar
      swaylock
      swayidle
      wl-clipboard
      grim
      slurp
      mako
      swaybg
      alacritty
    ];
    config = {
      xwayland = true;
    };
  };

  # Enable XWayland support
  programs.xwayland.enable = true;

  # Desktop-specific services
  services = {
    # Printing support
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.hplipWithPlugin ];
    };
    
    # Bluetooth support
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    
    # Other useful services
    openssh.enable = true;
    tailscale.enable = true;
  };

  # Fonts for better appearance
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    jetbrains-mono
    font-awesome
  ];

  # Multi-monitor support
  services.autorandr.enable = true;

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };
}
