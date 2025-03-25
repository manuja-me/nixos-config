{
  description = "NixOS configuration with Home Manager using flakes";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Add the Thorium browser flake as an input
    thorium-browser.url = "./thorium-browser";
  };
  
  outputs = { self, nixpkgs, home-manager, thorium-browser, ... }:
    let
      system = "x86_64-linux";
      variables = import ./variables.nix;
      
      # Configure nixpkgs with allowUnfree
      pkgsConfig = {
        allowUnfree = true;
        allowBroken = false;
      };
      
      # Create nixpkgs instance with our config
      pkgs = import nixpkgs {
        inherit system;
        config = pkgsConfig;
      };
      
      # Helper function to create machine-specific configurations
      mkMachine = { machineType ? variables.machineType }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit machineType; 
          inherit variables;
        };
        modules = [
          ./hosts/default.nix
          ./hosts/configuration.nix
          (if machineType == "laptop" then ./hosts/machine-specific/laptop.nix
           else if machineType == "desktop" then ./hosts/machine-specific/desktop.nix
           else if machineType == "vm" then ./hosts/machine-specific/vm.nix
           else ./hosts/machine-specific/laptop.nix)
          ./modules/default.nix
          ./modules/system/default.nix
          
          # Add global nixpkgs configuration
          {
            nixpkgs.config = pkgsConfig;
            nixpkgs.overlays = [ ];  # Add overlays if needed
          }
        ];
      };
    in {
      nixosConfigurations = {
        default = mkMachine { machineType = variables.machineType; };
        laptop = mkMachine { machineType = "laptop"; };
        desktop = mkMachine { machineType = "desktop"; };
        vm = mkMachine { machineType = "vm"; };
      };

      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        inherit system;
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { 
          inherit variables; 
          thoriumBrowser = thorium-browser.packages.${system}.default;
        };
        modules = [
          ./home-manager/default.nix
          ./home-manager/home.nix
          ./home-manager/programs/default.nix
          ./home-manager/programs/sway/default.nix
          ./home-manager/programs/waybar/default.nix
          ./home-manager/programs/neovim/default.nix
          ./home-manager/programs/alacritty/default.nix
          ./home-manager/programs/zsh/default.nix  # Add the ZSH configuration
          ./home-manager/programs/thunar/default.nix
          ./home-manager/themes/default.nix
          
          # Add global nixpkgs configuration for home-manager
          {
            nixpkgs.config = pkgsConfig;
            nixpkgs.overlays = [ ];  # Add overlays if needed
          }
          
          # Add Thorium browser config
          ({ pkgs, thoriumBrowser, ... }: {
            home.packages = [ thoriumBrowser ];
            
            # Set Thorium as the default browser
            xdg.mimeApps = {
              enable = true;
              defaultApplications = {
                "text/html" = "thorium-browser.desktop";
                "x-scheme-handler/http" = "thorium-browser.desktop";
                "x-scheme-handler/https" = "thorium-browser.desktop";
                "x-scheme-handler/about" = "thorium-browser.desktop";
                "x-scheme-handler/unknown" = "thorium-browser.desktop";
              };
            };
          })
        ];
      };
    };
}