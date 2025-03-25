{ 
  config, 
  pkgs, 
  ... 
}: { 
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
  services.networking.firewall.enable = true; 

  # Additional system configurations 
  networking.hostName = "nixos"; 
  time.timeZone = "UTC"; 
  users.users.yourusername = { 
    isNormalUser = true; 
    extraGroups = [ "wheel" "networkmanager" ]; 
  }; 
}