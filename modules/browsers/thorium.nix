{ config, pkgs, lib, variables, ... }:

with lib;

let
  cfg = config.programs.thorium-browser;
  thoriumConfig = variables.thorium or {};
  # Fallback to firefox if thorium-browser is not available
  hasThorium = false; # Set to true when thorium-browser input is available
in {
  options.programs.thorium-browser = {
    enable = mkEnableOption "Thorium Browser";
    
    package = mkOption {
      type = types.package;
      # Use firefox as fallback since thorium-browser is not available yet
      default = pkgs.firefox;
      description = "The Thorium browser package to use (fallback to firefox)";
    };
    
    defaultBrowser = mkOption {
      type = types.bool;
      default = thoriumConfig.defaultBrowser or false;
      description = "Whether to set Thorium as the default browser";
    };
    
    commandLineArgs = mkOption {
      type = types.listOf types.str;
      default = thoriumConfig.commandLineArgs or [];
      description = "Command line arguments to pass to Thorium";
      example = literalExpression ''
        [
          "--enable-features=UseOzonePlatform"
          "--ozone-platform=wayland"
        ]
      '';
    };
    
    enableWideVine = mkOption {
      type = types.bool;
      default = thoriumConfig.enableWideVine or false;
      description = "Whether to enable WideVine DRM support";
    };
  };

  config = mkIf cfg.enable {
    warnings = mkIf (!hasThorium) [
      "thorium-browser is not available, using firefox as fallback browser"
    ];
    
    environment.systemPackages = [ cfg.package ];
    
    # Set up environment variables for better wayland support
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";  # General Ozone Wayland support
      
      # If using DRM content with WideVine
      GOOGLE_DEFAULT_CLIENT_ID = mkIf cfg.enableWideVine "77185425430.apps.googleusercontent.com";
      GOOGLE_DEFAULT_CLIENT_SECRET = mkIf cfg.enableWideVine "OTJgUOQcT7lO7GsGZq2G4IlT";
    };
    
    # If defaultBrowser is true, set up systemwide default browser settings
    environment.sessionVariables = mkIf cfg.defaultBrowser {
      BROWSER = if hasThorium then "thorium-browser" else "firefox";
    };
  };
}