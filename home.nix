{ config, pkgs, ... }: {
  # Home Manager settings
  home.username = "youruser";  # Replace with your username
  home.homeDirectory = "/home/youruser";  # Replace with your home directory
  
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Home packages
  home.packages = with pkgs; [
    # Add your personal packages here
    htop
    ripgrep
    fd
  ];
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };
  
  # Terminal configuration
  programs.bash.enable = true;
  
  # State version
  home.stateVersion = "23.11";
}
