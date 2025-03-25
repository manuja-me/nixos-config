{
  description = "NixOS configuration with Home Manager using flakes";
  
  inputs = {
    # Ensure we're using nixos-unstable consistently
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Add thorium-browser input - point to local path
    thorium-browser.url = "../thorium-browser";
    # Uncomment when pushing to a remote repository:
    # thorium-browser.url = "github:yourusername/thorium-browser-nix";
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
        # Add Thorium browser overlay
        overlays = [
          (final: prev: {
            thorium-browser = thorium-browser.packages.${system}.default;
          })
        ];
      };
      
      # Helper function to create machine-specific configurations
      mkMachine = { machineType ? variables.machineType }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit machineType; 
          inherit variables;
          inherit thorium-browser;
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
          ./modules/browsers/thorium.nix  # Add the dedicated Thorium module
          
          # Add global nixpkgs configuration
          {
            nixpkgs.config = pkgsConfig;
            nixpkgs.overlays = [ 
              (final: prev: {
                thorium-browser = thorium-browser.packages.${system}.default;
              })
            ];
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
        inherit pkgs;
        extraSpecialArgs = { 
          inherit variables; 
          inherit thorium-browser;
        };
        modules = [
          ./home-manager/default.nix
          ./home-manager/home.nix
          ./home-manager/programs/default.nix
          ./home-manager/programs/sway/default.nix
          ./home-manager/programs/waybar/default.nix
          ./home-manager/programs/neovim/default.nix
          ./home-manager/programs/alacritty/default.nix
          ./home-manager/programs/zsh/default.nix
          ./home-manager/programs/thunar/default.nix
          ./home-manager/programs/thorium/default.nix  # Add the Thorium specific configuration
          ./home-manager/themes/default.nix
          
          # Add global nixpkgs configuration for home-manager
          {
            nixpkgs.config = pkgsConfig;
            nixpkgs.overlays = [ 
              (final: prev: {
                thorium-browser = thorium-browser.packages.${system}.default;
              })
            ];
          }
        ];
      };
    };
}