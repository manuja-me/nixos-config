{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";
  
  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/default.nix
          ./hosts/configuration.nix
          ./hosts/machine-specific/laptop.nix
        ];
      };
    };

    homeConfigurations = {
      user = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home-manager/default.nix
          ./home-manager/programs/default.nix
          ./home-manager/programs/neovim/default.nix
          ./home-manager/programs/waybar/default.nix
          ./home-manager/themes/default.nix
        ];
      };
    };
  };
}

{ config, pkgs, variables, ... }:

{
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = variables.username;
  home.homeDirectory = "/home/${variables.username}";

  # Import programs and themes
  imports = [
    ./programs/default.nix
    ./programs/sway/default.nix 
    ./programs/waybar/default.nix
    ./programs/neovim/default.nix
    ./programs/alacritty/default.nix
    ./programs/thunar/default.nix
    ./programs/mako/default.nix
    ./themes/default.nix
    ./home.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Enable 32-bit support (multilib equivalent)
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    # Add specific unfree packages here if needed
  ];
  
  # Support for 32-bit applications
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        libgdiplus
        libpulseaudio
      ];
      extraProfile = "export GDK_SCALE=2";
    };
  };

  # Ensure JetBrainsMono Nerd Font is installed
  fonts.fontconfig.enable = true;

  # Add the file manager script to PATH
  home.file.".local/bin/file-manager" = {
    source = ./bin/file-manager.sh;
    executable = true;
  };
  
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}