{ config, pkgs, ... }: {
  imports = [
    # Include your hardware configuration
    # ./hardware-configuration.nix
  ];

  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    # Replace with your hostname
    hostName = "yourhostname";
    networkmanager.enable = true;
  };

  # Set your time zone
  time.timeZone = "America/New_York"; # Change to your timezone
  
  # Define a user account
  users.users.youruser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  
  # Enable the X11 windowing system
  services.xserver.enable = true;
  
  # Enable a desktop environment (e.g., GNOME)
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  
  # Wayland support for Thorium
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  
  # Allow unfree packages (as needed)
  nixpkgs.config.allowUnfree = true;
  
  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    # Basic packages
  ];

  # Enable the OpenSSH daemon
  # services.openssh.enable = true;
  
  system.stateVersion = "23.11"; # Set to the version you're using
}
