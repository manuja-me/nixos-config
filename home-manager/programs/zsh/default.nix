let
  variables = import ./../../../variables.nix;
in
{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "sudo"
        "history"
        "docker"
        "command-not-found"
      ];
    };
    
    # Git aliases
    shellAliases = {
      # Git aliases
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gapa = "git add --patch";
      gb = "git branch";
      gba = "git branch -a";
      gbd = "git branch -d";
      gc = "git commit -v";
      gca = "git commit -v -a";
      gcam = "git commit -a -m";
      gcmsg = "git commit -m";
      gco = "git checkout";
      gd = "git diff";
      gf = "git fetch";
      gl = "git pull";
      gm = "git merge";
      gp = "git push";
      gpsup = "git push --set-upstream origin $(git_current_branch)";
      gr = "git remote";
      gst = "git status";
      
      # Navigation aliases
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      ll = "ls -la";
      la = "ls -a";
      l = "ls -CF";
      
      # NixOS specific aliases
      nrb = "sudo nixos-rebuild switch --flake .#default";
      nrbt = "sudo nixos-rebuild test --flake .#default";
      nrbb = "sudo nixos-rebuild boot --flake .#default";
      hms = "home-manager switch --flake .#default";
      nfu = "nix flake update";
      nsp = "nix-shell -p";
      ns = "nix search nixpkgs";
      nsh = "nix-shell";
      nixclean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      nixupgrade = "nfu && nrb && hms";
      
      # Application shortcuts
      term = "alacritty";
      browser = "thorium-browser";
      
      # File manager aliases
      fm = "yazi";  # Terminal file manager
      gfm = "thunar"; # GUI file manager
    };
    
    initExtra = ''
      # Additional ZSH configuration
      
      # History settings
      HISTSIZE=10000
      SAVEHIST=10000
      HISTFILE=~/.zsh_history
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_FIND_NO_DUPS
      
      # Custom key bindings
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      
      # Custom functions
      
      # Quickly create and cd into a new directory
      take() {
        mkdir -p $1
        cd $1
      }
      
      # Extract common archive formats
      extract() {
        if [ -f $1 ] ; then
          case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }
      
      # Information about NixOS generations
      nixinfo() {
        echo "NixOS System Generations:"
        sudo nix-env -p /nix/var/nix/profiles/system --list-generations
        
        echo "\nHome Manager Generations:"
        home-manager generations
      }
      
      # Get the status of system and home-manager config
      nixstatus() {
        echo "System flake:"
        git -C ~/.config/nixos status
        
        echo "\nHome Manager flake:"
        git -C ~/.config/home-manager status
      }
      
      # Use Yazi as default file viewer in terminal
      function open() {
        if [ -d "$1" ]; then
          yazi "$1"
        else
          xdg-open "$1"
        fi
      }
    '';
  };
}
