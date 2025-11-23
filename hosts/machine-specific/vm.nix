{ config, pkgs, lib, ... }:

{
  # VM-specific packages (minimal setup for best performance)
  environment.systemPackages = with pkgs; [
    # Core packages
    firefox-esr
    neovim
    git
    
    # Wayland environment (lightweight)
    xwayland
    wofi
    waybar  # waybar-minimal doesn't exist, using waybar
    swaylock
    wl-clipboard
    
    # System utilities
    htop
    ncdu
    curl
    wget
  ];

  # Enable networking with specific VM settings
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ]; # Open common ports
    };
  };

  # Hardware configuration optimized for VM
  hardware = {
    enableRedistributableFirmware = true;
    opengl = {
      enable = true;
      driSupport = true;
    };
  };

  # X11 and Wayland configuration
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    videoDrivers = [ "qxl" "virtio" ]; # QEMU-specific drivers
  };

  # Sway specific configurations (optimized for VM)
  # Note: programs.sway is already configured in hosts/configuration.nix
  # Commenting out to avoid conflicts
  # services.sway = {
  #   enable = true;
  #   wrapperFeatures.gtk = true;
  #   extraPackages = with pkgs; [
  #     xwayland
  #     wofi
  #     waybar-minimal
  #     swaylock
  #     wl-clipboard
  #     alacritty
  #   ];
  #   config = {
  #     xwayland = true;
  #   };
  # };

  # Enable XWayland support
  programs.xwayland.enable = true;

  # VM guest additions
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  
  # VM-specific services
  services = {
    # Basic services for VM
    openssh.enable = true;
  };

  # Fonts (minimal set for VM)
  fonts.packages = with pkgs; [
    noto-fonts
    liberation_ttf
    fira-code
  ];

  # Memory and performance tuning for VM
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  # Power management (VM-specific)
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil"; # Best for VMs
  };

  # Auto-login for VM environments
  services.getty.autologinUser = "user";
}
