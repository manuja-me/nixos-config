{
  "home-manager": {
    "programs": {
      "default.nix": {
        "programs": {
          "sway": {
            "enable": true,
            "config": ./sway/config
          },
          "alacritty": {
            "enable": true,
            "config": {
              "font": {
                "normal": {
                  "family": "Fira Code",
                  "style": "Regular"
                },
                "bold": {
                  "family": "Fira Code",
                  "style": "Bold"
                }
              },
              "colors": {
                "primary": {
                  "background": "#282828",
                  "foreground": "#ebdbb2"
                }
              }
            }
          },
          "wofi": {
            "enable": true,
            "style": '''
              * {
                font-family: "JetBrainsMono Nerd Font";
                font-size: 12pt;
              }
              window {
                margin: 5px;
                border: 2px solid ${variables.colors.active.primary.light};
                background-color: ${variables.colors.active.background};
                border-radius: 0px;
              }
              #input {
                margin: 5px;
                border: 2px solid ${variables.colors.active.primary.light};
                background-color: ${variables.colors.active.primary.dark};
                color: ${variables.colors.active.foreground};
              }
              #outer-box {
                margin: 20px;
                background-color: ${variables.colors.active.background};
                color: ${variables.colors.active.foreground};
              }
              #entry:selected {
                background-color: ${variables.colors.active.primary.light};
                color: ${variables.colors.active.brightAccent.green};
              }
            ''',
            "settings": {
              "show" = "drun";
              "width" = 500;
              "height" = 300;
              "always_parse_args" = true;
              "show_all" = true;
              "print_command" = true;
              "layer" = "overlay";
              "insensitive" = true;
            }
          },
          "waybar": {
            "enable": true,
            "package": "waybar",
            "settings": {
              "mainBar": {
                // See waybar/default.nix for full configuration
              }
            }
          },
          "mako": {
            "enable": true,
            "backgroundColor": "${variables.colors.active.background}",
            "textColor": "${variables.colors.active.foreground}",
            "borderColor": "${variables.colors.active.primary.light}",
            "borderRadius": 0,
            "borderSize": 2,
            "defaultTimeout": 5000
          },
          "swaylock": {
            "enable": true,
            "settings": {
              "color": "${variables.colors.active.background}",
              "indicator-radius": 100,
              "indicator-thickness": 7,
              "inside-color": "${variables.colors.active.background}",
              "inside-clear-color": "${variables.colors.active.accent.yellow}",
              "inside-ver-color": "${variables.colors.active.accent.blue}",
              "inside-wrong-color": "${variables.colors.active.accent.red}",
              "key-hl-color": "${variables.colors.active.brightAccent.green}",
              "line-color": "${variables.colors.active.primary.light}",
              "ring-color": "${variables.colors.active.primary.light}",
              "ring-clear-color": "${variables.colors.active.accent.yellow}",
              "ring-ver-color": "${variables.colors.active.accent.blue}",
              "ring-wrong-color": "${variables.colors.active.accent.red}",
              "separator-color": "${variables.colors.active.background}",
              "text-color": "${variables.colors.active.foreground}"
            }
          },
          "zsh": {
            "enable": true,
            "enableAutosuggestions": true,
            "enableCompletion": true,
            "enableSyntaxHighlighting": true,
            "oh-my-zsh": {
              "enable": true,
              "theme": "robbyrussell",
              "plugins": [
                "git",
                "sudo",
                "history",
                "docker",
                "command-not-found"
              ]
            },
            "initExtra": ''
              # Additional zsh initialization code
              bindkey '^[[A' history-substring-search-up
              bindkey '^[[B' history-substring-search-down
            ''
          },
          "yazi": {
            "enable": true,
            "enableZshIntegration": true,
            "settings": {
              "manager": {
                "show_hidden": true,
                "sort_by": "modified",
                "sort_reverse": true
              },
              "preview": {
                "tab_size": 2,
                "max_width": 1000,
                "max_height": 1000
              },
              "opener": {
                "text": ["nvim"]
              }
            },
            "theme": {
              "manager": {
                "border_style": {
                  "fg": "${variables.colors.active.primary.light}",
                  "bg": "reset"
                },
                "border_style_active": {
                  "fg": "${variables.colors.active.brightAccent.green}",
                  "bg": "reset"
                }
              },
              "status": {
                "separator_style": {
                  "fg": "${variables.colors.active.primary.light}",
                  "bg": "reset"
                }
              },
              "selection": {
                "fg": "${variables.colors.active.foreground}",
                "bg": "${variables.colors.active.primary.light}"
              }
            }
          },
          "thunar": {
            "enable": true,
            "plugins": ["thunar-archive-plugin", "thunar-volman"]
          }
        }
      }
    }
  }
}