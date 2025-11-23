{ 
  config, 
  pkgs, 
  lib, 
  ... 
}: 

let
  variables = import ./../variables.nix;
in
{ 
  imports = [ 
    ./configuration.nix 
  ]; 

  # Configure the boot loader based on variables
  boot.loader = if variables.boot.loader == "grub" then {
    grub = {
      enable = true;
      device = variables.boot.grub.device or "nodev";
      efiSupport = true;
      useOSProber = variables.boot.grub.useOSProber or true;
      backgroundColor = variables.boot.grub.backgroundColor;
      fontSize = variables.boot.grub.fontSize;
    };
    
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    
    timeout = variables.boot.timeout or 5;
    systemd-boot.enable = false;
  } else {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      consoleMode = "auto";
    };
    
    efi = {
      canTouchEfiVariables = true;
    };
    
    timeout = variables.boot.timeout or 5;
    grub.enable = false;
  };

  # System settings
  networking.hostName = variables.hostname; # Using the hostname from variables
  networking.networkmanager.enable = true; 

  # Time settings
  time.timeZone = variables.timezone or "UTC"; 

  # Enable some basic services
  services.openssh.enable = true; 
  networking.firewall.enable = true; 
  networking.firewall.allowedTCPPorts = [ 22 ]; 

  # Users
  users.users.${variables.username} = { # Using the username from variables
    isNormalUser = true; 
    extraGroups = [ "wheel" "networkmanager" ]; 
  }; 

  # System packages
  environment.systemPackages = with pkgs; [ 
    wget 
    vim 
    git 
  ]; 
}