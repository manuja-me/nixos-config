{ config, pkgs, lib, thorium-browser, variables, ... }:

let
  thoriumConfig = variables.thorium or {};
in {
  home.packages = [
    # Use the thorium-browser from the flake
    thorium-browser.packages.${pkgs.system}.default
  ];
  
  # Set as default browser if configured
  xdg.mimeApps = lib.mkIf (thoriumConfig.defaultBrowser or false) {
    enable = true;
    defaultApplications = {
      "text/html" = "thorium-browser.desktop";
      "x-scheme-handler/http" = "thorium-browser.desktop";
      "x-scheme-handler/https" = "thorium-browser.desktop";
      "x-scheme-handler/about" = "thorium-browser.desktop";
      "x-scheme-handler/unknown" = "thorium-browser.desktop";
    };
  };
  
  # Create custom configuration directories
  home.file.".config/thorium-browser/Default/Preferences".text = builtins.toJSON {
    browser = {
      has_seen_welcome_page = true;
      custom_chrome_frame = false;
      show_home_button = true;
      check_default_browser = false;
      custom_javascript_setting = 1; # Allow JavaScript
    };
    bookmark_bar = {
      show_on_all_tabs = true;
    };
    distribution = {
      import_bookmarks = false;
      import_history = false;
      import_home_page = false;
      import_search_engine = false;
      suppress_first_run_bubble = true;
      do_not_create_desktop_shortcut = true;
      do_not_create_quick_launch_shortcut = true;
      do_not_launch_chrome = true;
      do_not_register_for_update_launch = true;
    };
    download = {
      default_directory = "${config.home.homeDirectory}/Downloads";
      prompt_for_download = true;
    };
    profile = {
      default_content_setting_values = {
        notifications = 2; # Block notifications
      };
    };
    search = {
      suggest_enabled = false;
    };
    translate = {
      enabled = false;
    };
    hardware_acceleration_mode_enabled = true;
    privacy_sandbox = {
      m1 = {
        topics_enabled = false;
        fledge_enabled = false;
      };
    };
    alternate_error_pages = {
      enabled = false;
    };
    credentials_enable_service = false;
    safe_browsing = {
      enabled = false; # Disable Google Safe Browsing
    };
  };
  
  # Add a custom script to apply browser flags
  home.file.".local/bin/thorium-browser-custom" = {
    text = ''
      #!/bin/sh
      exec ${thorium-browser.packages.${pkgs.system}.default}/bin/thorium-browser ${lib.concatStringsSep " " (thoriumConfig.commandLineArgs or [])} "$@"
    '';
    executable = true;
  };
  
  # Add to PATH
  home.sessionPath = [ 
    "$HOME/.local/bin" 
  ];
}
