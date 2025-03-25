{ config, pkgs, lib, variables, ... }:

let
  inherit (variables) thorium;
in
{
  programs.chromium = {
    enable = true;
    package = pkgs.thorium-browser;
    
    # Command line arguments
    commandLineArgs = thorium.commandLineArgs or [];
    
    # Browser extensions
    extensions = [
      # Add your extensions here
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
    ];
    
    # Default search provider
    defaultSearchProviderEnabled = true;
    defaultSearchProviderSearchURL = "https://search.brave.com/search?q={searchTerms}";
    
    # Browser settings
    extraOpts = {
      "BrowserSignin" = 0; # Disable browser sign-in
      "SyncDisabled" = true; # Disable sync
      "PasswordManagerEnabled" = false; # Disable built-in password manager
      "AutofillAddressEnabled" = false; # Disable address autofill
      "AutofillCreditCardEnabled" = false; # Disable credit card autofill
      "BookmarkBarEnabled" = true; # Enable bookmark bar
      "HomepageIsNewTabPage" = true; # New tab as homepage
      "RestoreOnStartup" = 5; # Continue where you left off
    };
  };
  
  # Set as default browser if configured
  xdg.mimeApps = lib.mkIf (thorium.defaultBrowser or false) {
    enable = true;
    defaultApplications = {
      "text/html" = "thorium-browser.desktop";
      "x-scheme-handler/http" = "thorium-browser.desktop";
      "x-scheme-handler/https" = "thorium-browser.desktop";
      "x-scheme-handler/about" = "thorium-browser.desktop";
      "x-scheme-handler/unknown" = "thorium-browser.desktop";
    };
  };
}
