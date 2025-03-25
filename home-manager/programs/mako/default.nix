let
  variables = import ./../../../variables.nix;
  colors = variables.colors.active;
in
{
  programs.mako = {
    enable = true;
    iconPath = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
    font = "${variables.theme.font.family} ${toString variables.theme.font.size}";
    padding = "10";
    margin = "10";
    borderSize = 2;
    borderRadius = 0;
    defaultTimeout = 5000;
    
    # Themed colors
    backgroundColor = colors.background;
    textColor = colors.foreground;
    borderColor = colors.primary.light;
    
    # Category-specific styling
    extraConfig = ''
      [category=power]
      background-color=${colors.accent.blue}
      border-color=${colors.brightAccent.blue}
      default-timeout=3000
      
      [category=volume]
      background-color=${colors.accent.green}
      border-color=${colors.brightAccent.green}
      default-timeout=1000
      
      [category=brightness]
      background-color=${colors.accent.yellow}
      border-color=${colors.brightAccent.yellow}
      default-timeout=1000
      
      [category=network]
      background-color=${colors.accent.cyan}
      border-color=${colors.brightAccent.cyan}
      default-timeout=3000
      
      [category=system]
      background-color=${colors.accent.pink}
      border-color=${colors.brightAccent.pink}
      default-timeout=10000
      
      [urgency=critical]
      background-color=${colors.accent.red}
      border-color=${colors.brightAccent.red}
      default-timeout=0
    '';
  };
}
