{ 
  config, 
  pkgs, 
  ... 
}: 

let
  variables = import ./../../variables.nix;
in
{ 
  # System-level configurations 
  imports = [ 
    ./../../hosts/default.nix 
    ./../../hosts/configuration.nix 
    ./../../home-manager/default.nix 
    ./../../modules/default.nix 
  ]; 

  # Define system packages 
  environment.systemPackages = with pkgs; [ 
    # Add your desired packages here 
    vim 
    git 
    wget 
  ]; 

  # Enable services 
  services.openssh.enable = true; 
  services.firewall.enable = true; 

  # Additional system configurations 
  networking.hostName = variables.hostname or "nixos"; 
  time.timeZone = variables.timezone or "UTC"; 
  users.users.${variables.username or "nixos"} = { 
    isNormalUser = true; 
    extraGroups = [ "wheel" "networkmanager" ]; 
  }; 
}