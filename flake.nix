{
  description = "NixOS configuration with Home Manager using flakes";
  
  inputs = {
    # Ensure we're using nixos-unstable consistently
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Add thorium-browser input when ready
    # NOTE: The thorium-browser directory does not exist yet.
    # Uncomment when the thorium-browser flake is available:
    # thorium-browser.url = "path:../thorium-browser";
    # Or from a remote repository:
    # thorium-browser.url = "github:yourusername/thorium-browser-nix";
  };
  
  outputs = { self, nixpkgs, home-manager, ... }@inputs:
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
        # Add overlays when thorium-browser is available
        # overlays = [
        #   (final: prev: {
        #     thorium-browser = thorium-browser.packages.${system}.default;
        #   })
        # ];
      };
      
      # Helper function to create machine-specific configurations
      mkMachine = { machineType ? variables.machineType }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit machineType; 
          inherit variables;
          # thorium-browser will be available when uncommented in inputs
          # inherit thorium-browser;
        };
        modules = [
          ./hosts/default.nix
          ./hosts/configuration.nix
          (if machineType == "laptop" then ./hosts/machine-specific/laptop.nix
           else if machineType == "desktop" then ./hosts/machine-specific/desktop.nix
           else if machineType == "vm" then ./hosts/machine-specific/vm.nix
           else ./hosts/machine-specific/laptop.nix)
          ./modules/default.nix
          # Uncomment when thorium-browser is available:
          # ./modules/browsers/thorium.nix
          
          # Add global nixpkgs configuration
          {
            nixpkgs.config = pkgsConfig;
            # Uncomment overlays when thorium-browser is available:
            # nixpkgs.overlays = [ 
            #   (final: prev: {
            #     thorium-browser = thorium-browser.packages.${system}.default;
            #   })
            # ];
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
          # thorium-browser will be available when uncommented in inputs
          # inherit thorium-browser;
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
          # Uncomment when thorium-browser is available:
          # ./home-manager/programs/thorium/default.nix
          ./home-manager/themes/default.nix
          
          # Add global nixpkgs configuration for home-manager
          {
            nixpkgs.config = pkgsConfig;
            # Uncomment overlays when thorium-browser is available:
            # nixpkgs.overlays = [ 
            #   (final: prev: {
            #     thorium-browser = thorium-browser.packages.${system}.default;
            #   })
            # ];
          }
        ];
      };
    };
}