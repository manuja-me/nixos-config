{ config, pkgs, ... }: {
  # NOTE: This is an EXAMPLE configuration file at the repository root.
  # The actual system configuration is in hosts/configuration.nix
  # This file is not imported by flake.nix and is here for reference only.
  
  imports = [
    # Include your hardware configuration
    # ./hardware-configuration.nix
  ];

  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    # Replace with your hostname (or use variables.nix)
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Set your time zone
  time.timeZone = "America/New_York"; # Change to your timezone
  
  # Define a user account (or use variables.nix)
  users.users.nixos = {
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
  
  # Wayland support
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
