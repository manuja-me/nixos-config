{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # List of packages specific to the laptop
    firefox
    neovim
    git
    xwayland
    wofi
    waybar
    swaylock
    swayidle
    wl-clipboard
    grim
    slurp
    mako
    swaybg
    alacritty # terminal
    dmenu # application launcher
    # Add more packages as needed
  ];

  networking.networkmanager.enable = true;

  hardware.enableAllFirmware = true;

  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;

  # Note: programs.sway is already configured in hosts/configuration.nix
  # This avoids conflicts between services.sway and programs.sway

  # Enable XWayland support
  programs.xwayland.enable = true;

  # Additional laptop-specific settings
  powerManagement.enable = true;
  powerManagement.laptop.enable = true;

  # Fonts for better appearance
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];

  # Define any other machine-specific configurations here
}