{ 
  config, 
  pkgs, 
  ... 
}: 

let
  variables = import ./../variables.nix;
in
{ 
  imports = [ 
    ./configuration.nix 
  ]; 

  # System settings
  networking.hostName = variables.hostname; # Using the hostname from variables
  networking.networkmanager.enable = true; 

  # Time settings
  time.timeZone = "UTC"; 

  # Enable some basic services
  services.openssh.enable = true; 
  services.firewall.enable = true; 
  services.firewall.allowedTCPPorts = [ 22 ]; 

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

  # Enable NixOS services
  systemd.services.exampleService = { 
    description = "Example Service"; 
    wantedBy = [ "multi-user.target" ]; 
    serviceConfig = { 
      ExecStart = "${pkgs.examplePackage}/bin/example"; 
    }; 
  }; 
}