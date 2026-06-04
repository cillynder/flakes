{ config, inputs, pkgs, ... }:
let
  dotnet-combined = (with pkgs.dotnetCorePackages; combinePackages [
      dotnet_10.sdk
      aspnetcore_10_0-bin
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
    pnpm
    unrar
    yt-dlp
  ] ++ lib.optionals (config.me.environment == "desktop") [
    krita
    lutris
    mangohud
    inputs.nix-gaming.packages.x86_64-linux.osu-lazer-bin
    qmk
    tetrio-desktop
    tor-browser
    virt-manager
    winetricks
  ] ++ lib.optionals config.me.gui [
    android-studio
    brightnessctl
    drawio
    evince
    eww
    feh
    feishin
    file-roller
    gamescope
    gimp3
    grim
    lm_sensors
    maim
    me.psensor
    obsidian
    pavucontrol
    (prismlauncher.override {
      jdks = [
        jdk21
        temurin-bin-25
      ];
    })
    qbittorrent
    rivalcfg
    screenkey
    slurp
    swaybg
    texliveFull
    transmission-remote-gtk
    vesktop
    zathura
    zenity

    (vscode.fhsWithPackages (_: [ dotnet-combined ]))
    dotnet-combined
  ];
}
