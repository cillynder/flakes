# vim: ft=nix
{ config, inputs, pkgs, sysConfig, ... }:
let
  lib = pkgs.lib;

  pluginFromInput = name: {
    inherit name;
    src = inputs.${name};
  };

  abbrs = {
    e = "$EDITOR";
    rs = "source ~/.config/zsh/.zshrc";

    ll = "ls -al";
    q = "exit";

    peach = "ssh lava@peach";
    bunny = "ssh bunny@peach";

    fa = "grep -Inr";
    fai = "grep -Iinr";

    g1 = "xgamma -gamma 1";
    g3 = "xgamma -gamma 1.3";

    bat = "echo 'battery' | doas tee /sys/class/drm/card1/device/power_dpm_state";
    bal = "echo 'balanced' | doas tee /sys/class/drm/card1/device/power_dpm_state";
    sclk = "doas setclock 50000 70000 800";

    sysu = "doas systemctl restart";
    sysd = "doas systemctl stop";
    syss = "doas systemctl status";
    usysu = "systemctl --user restart";
    usysd = "systemctl --user stop";
    usyss = "systemctl --user status";
    j = "doas journalctl -b";
    jf = "doas journalctl -f";

    fl = "cd ~/Projects/flakes";
    nr = "nh os switch";
    nb = "nh os boot";

    gs = "git status";
    ga = "git add";
    gaa = "git add .";
    gc = "git commit";
    gac = "git add .; git commit";
    gcm = "git commit -m";
    gco = "git checkout";
    gd = "git diff";
    gds = "git diff --staged";
    gf = "git commit --amend --reset-author --no-edit";
    gfe = "git commit --amend --reset-author";
    gl = "git log";
    gr = "git rebase -i";
  };

  genAbbrs = lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "abbr add -S --quiet ${k}=${lib.escapeShellArg v}") abbrs);
  cursorShape = ''
    function zle-keymap-select {
      if [[ $KEYMAP == vicmd ]] ||
         [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'
      elif [[ $KEYMAP == main ]] ||
           [[ $KEYMAP == viins ]] ||
           [[ $KEYMAP = "" ]] ||
           [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'
      fi
    }
    zle -N zle-keymap-select
    zle-line-init() {
        zle -K viins
        echo -ne "\e[5 q"
    }
    zle -N zle-line-init
    echo -ne '\e[5 q'
    preexec() { echo -ne '\e[5 q' ;}
  '';
  direnv = ''
    eval "$(direnv hook zsh)"
  '';
  pure = ''
    autoload -U promptinit; promptinit
    prompt pure
  '';
  viExtraNav = ''
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'j' vi-down-line-or-history

    bindkey -v '^?' backward-delete-char
    bindkey -v '^R' history-incremental-pattern-search-backward
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
  '';
  disableExecute = ''
    bindkey -a -r ':'
  '';
in {
  programs.command-not-found.enable = true;
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    autocd = true;
    defaultKeymap = "viins";

    history = {
      extended = true;
      path = "${config.xdg.dataHome}/zsh/history";
      save = 10000000;
      size = 10000000;
    };

    enableCompletion = true;

    localVariables = {
      KEYTIMEOUT = "1";
      #PS1 = "%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b ";
      ZSH_AUTOSUGGEST_STRATEGY = [ "completion" ];
      ZSH_AUTOSUGGEST_USE_ASYNC = true;
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = 40;
    };

    shellAliases = {
      ls = "ls --color=auto --group-directories-first -v";
      diff = "diff -Naur --color=auto";
    };
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        autoload -U colors && colors
      '')
      (lib.mkOrder 550 ''
        fpath+=(/run/current-system/sw/share/zsh/site-functions)
        zstyle ':completion:*' completer _complete
        zstyle ':completion:*' matcher-list "" 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' '+l:|=* r:|=*'
        zstyle ':completion:*' menu select
        _comp_options+=(globdots)
        zmodload zsh/complist
      '')
      (lib.concatStringsSep "\n" [
        pure
        cursorShape
        direnv
        genAbbrs
        viExtraNav
        disableExecute
      ])
    ];

    plugins = builtins.map (e: pluginFromInput e) [
      "pure"
      "zsh-abbr"
      "zsh-history-substring-search"
      "fast-syntax-highlighting"
    ] ++ [{
      name = "zsh-autosuggestions";
      src = pkgs.zsh-autosuggestions + "/share/zsh-autosuggestions";
      file = "zsh-autosuggestions.zsh";
    }];
  };
}
