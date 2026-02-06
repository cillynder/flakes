{ config, inputs, pkgs, ... }:
let
  dotnet-combined = (with pkgs.dotnetCorePackages; combinePackages [
      dotnet_8.sdk
      dotnet_9.sdk
      aspnetcore_8_0-bin
      aspnetcore_9_0-bin
  ]);
in {
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [];
  };

  home.packages = with pkgs; [
    dconf
    ffmpeg
    gnupg
    kitty
    nil
    nodejs_latest
    pamixer
    qmk
    unrar
    weechat
    yt-dlp

    nodePackages_latest.pnpm
  ] ++ lib.optionals config.me.gui [
    android-studio
    drawio
    element-desktop
    evince
    eww
    feh
    file-roller
    gamescope
    gimp3
    grim
    #kotatogram-desktop
    krita
    lm_sensors
    lutris
    insomnia
    maim
    mangohud
    me.psensor
    inputs.nix-gaming.packages.x86_64-linux.osu-lazer-bin
    inputs.nix-gaming.packages.x86_64-linux.wine-osu
    obsidian
    pavucontrol
    prismlauncher
    qbittorrent
    rivalcfg
    screenkey
    slurp
    swaybg
    tetrio-desktop
    texliveFull
    tor-browser
    transmission-remote-gtk
    vesktop
    virt-manager
    winetricks
    zathura
    zenity

    (vscode.fhsWithPackages (_: [ dotnet-combined ]))
    dotnet-combined
  ];
}
