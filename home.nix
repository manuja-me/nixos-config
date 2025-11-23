{ config, pkgs, ... }: {
  # NOTE: This is an EXAMPLE home.nix file at the repository root.
  # The actual home-manager configuration is in home-manager/home.nix
  # This file is not imported by flake.nix and is here for reference only.
  
  # Home Manager settings
  home.username = "nixos";  # Replace with your username or use variables.nix
  home.homeDirectory = "/home/nixos";  # Replace with your home directory
  
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
