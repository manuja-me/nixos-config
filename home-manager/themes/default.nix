let
  variables = import ./../../variables.nix;
in
{
  "inputs": {
    "nixpkgs": {
      "url": "github:NixOS/nixpkgs/nixos-unstable"
    }
  },
  "outputs": {
    "homeManager": {
      "theme": {
        "name": variables.theme.name,
        "colors": {
          "background": variables.colors.active.background,
          "foreground": variables.colors.active.foreground,
          "cursor": variables.colors.active.brightAccent.orange,
          "black": variables.colors.active.background,
          "red": variables.colors.active.accent.red,
          "green": variables.colors.active.accent.green,
          "yellow": variables.colors.active.accent.yellow,
          "blue": variables.colors.active.accent.blue,
          "magenta": variables.colors.active.accent.pink,
          "cyan": variables.colors.active.accent.cyan,
          "white": variables.colors.active.primary.light,
          "brightBlack": variables.colors.gruvbox.dark.primary.light,
          "brightRed": variables.colors.active.brightAccent.red,
          "brightGreen": variables.colors.active.brightAccent.green,
          "brightYellow": variables.colors.active.brightAccent.yellow,
          "brightBlue": variables.colors.active.brightAccent.blue,
          "brightMagenta": variables.colors.active.brightAccent.pink,
          "brightCyan": variables.colors.active.brightAccent.cyan,
          "brightWhite": variables.colors.active.foreground
        }
      }
    }
  }
}