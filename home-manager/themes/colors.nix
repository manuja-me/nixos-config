let
  gruvboxColors = import ./../../themes/gruvbox.nix;
in
{
  colors = {
    # Use the centralized Gruvbox colors
    background = gruvboxColors.gruvbox.dark.background;
    foreground = gruvboxColors.gruvbox.dark.foreground;
    primary = gruvboxColors.gruvbox.dark.primary;
    accent = gruvboxColors.gruvbox.dark.accent;
    border = gruvboxColors.gruvbox.dark.border;
    brightAccent = gruvboxColors.gruvbox.dark.brightAccent;
    gruvbox = gruvboxColors.gruvbox;
    
    # Set active theme to gruvbox dark by default
    active = gruvboxColors.gruvbox.dark;
  };
}