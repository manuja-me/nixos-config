{ 
  config, 
  pkgs, 
  lib,
  ... 
}: 

let
  variables = import ./../../variables.nix;
in
{ 
  # System-level module configurations
  # Note: This module provides additional system-level options
  # It should NOT import the main configuration files to avoid circular dependencies
  
  # Define system packages 
  environment.systemPackages = with pkgs; [ 
    # Add your desired packages here 
    vim 
    git 
    wget 
  ]; 

  # Enable services 
  services.openssh.enable = true; 
  networking.firewall.enable = true; 

  # Additional system configurations 
  networking.hostName = lib.mkDefault (variables.hostname or "nixos"); 
  time.timeZone = lib.mkDefault (variables.timezone or "UTC"); 
  users.users.${variables.username or "nixos"} = { 
    isNormalUser = true; 
    extraGroups = [ "wheel" "networkmanager" ]; 
  }; 
}