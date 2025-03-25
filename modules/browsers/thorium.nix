{ config, pkgs, lib, thorium-browser, variables, ... }:

with lib;

let
  cfg = config.programs.thorium-browser;
  thoriumConfig = variables.thorium or {};
in {
  options.programs.thorium-browser = {
    enable = mkEnableOption "Thorium Browser";
    
    package = mkOption {
      type = types.package;
      default = thorium-browser.packages.${pkgs.system}.default;
      description = "The Thorium browser package to use";
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
    environment.systemPackages = [ cfg.package ];
    
    # Set up environment variables for better wayland support
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";  # General Ozone Wayland support
      
      # If using DRM content with WideVine
      GOOGLE_DEFAULT_CLIENT_ID = mkIf cfg.enableWideVine "77185425430.apps.googleusercontent.com";
      GOOGLE_DEFAULT_CLIENT_SECRET = mkIf cfg.enableWideVine "OTJgUOQcT7lO7GsGZq2G4IlT";
    };
    
    # Install a wrapper script to launch Thorium with custom flags
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "thorium-browser-launcher" ''
        exec ${cfg.package}/bin/thorium-browser ${concatStringsSep " " cfg.commandLineArgs} "$@"
      '')
    ];

    # If defaultBrowser is true, set up systemwide default browser settings
    environment.sessionVariables = mkIf cfg.defaultBrowser {
      BROWSER = "thorium-browser";
    };
    
    # Create XDG desktop entry with appropriate flags
    environment.systemPackages = [
      (pkgs.makeDesktopItem {
        name = "thorium-browser-custom";
        desktopName = "Thorium Browser";
        exec = "thorium-browser-launcher %U";
        icon = "thorium-browser";
        categories = ["Network" "WebBrowser"];
        mimeTypes = [
          "text/html"
          "application/xhtml+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];
        genericName = "Web Browser";
      })
    ];
  };
}
