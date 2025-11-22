{ config, modules, pkgs, ... }: {
  programs.nh.flake = "/home/rin/Projects/flakes";
  programs.zsh.enable = true;
  users.users.rin = {
    isNormalUser = true;
    extraGroups = [ "adbusers" "audio" "corectrl" "dialout" "libvirtd" "networkmanager" "video" "wheel" "wireshark" ];
    shell = pkgs.zsh;
    uid = 1001;
    hashedPasswordFile = config.age.secrets.passwd.path;
  };
  home-manager.users.rin = { config, lib, pkgs, ... }: {
    home = {
      username = "rin";
      homeDirectory = "/home/rin";
      stateVersion = "21.05";
      keyboard = null; # see https://github.com/nix-community/home-manager/issues/2219
    };

    imports = with modules.user; [
      ./packages.nix
      sessionVariables

      catppuccin
      direnv
      git
      gpg
      neovim
      npm
      zsh
    # HACK: include all gui for now due to infinite recursion (inability to dynamically control imports)
    # ] ++ lib.optionals config.me.gui [
    ] ++ [
      theming
      xdg

      hypridle
      hyprlock
      kitty
      mpv
      obs
      rofi

      dunst
      eww

      spicetify
    ];

    services.mpris-proxy.enable = true;
    home.packages = [ pkgs.wl-clipboard ];

    home.file.".local/bin/ipc-bridge.exe".source = builtins.fetchurl {
      url = "https://github.com/0e4ef622/wine-discord-ipc-bridge/releases/download/v0.0.1/winediscordipcbridge.exe";
      sha256 = "1swn9spxpq6blm74kjmfz4ipq6a8qjzccvb2msb25pf5b1z7jnns";
    };
    home.file.".local/bin/osu" = {
      executable = true;
      source = ../../scripts/osu;
    };
  };
}
