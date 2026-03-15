{ config, inputs, modules, overlays, pkgs, ... }: {
  networking.hostName = "anemone";
  system.stateVersion = "23.11";
  time.timeZone = "Australia/Melbourne";

  nixpkgs.overlays = [ inputs.neovim-nightly.overlays.default ];
  age.secrets = {
    wg_anemone.file = ../../secrets/wg_anemone.age;
    passwd.file = ../../secrets/passwd.age;
  };

  imports = with modules.system; [
    home-manager

    audio
    base
    bluetooth
    ccache
    corectrl
    docker
    flatpak
    greetd
    gui
    input
    kernel
    nix
    packages
    printing
    security
    snapper
    wireguard

    inputs.c-citrine.nixosModule

    ./filesystem.nix
    ./kernel.nix
    ./networking.nix

    ../../users/rin

    modules.services.syncthing
  ];

  me = {
    environment = "laptop";
    batteryDevice = "BATT";
    kbBacklightDevice = "asus::kbd_backlight";
    hasFingerprint = true;
    hidpi = true;
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  services.fprintd.enable = true;
  services.tlp.enable = true;

  programs.kdeconnect.enable = true;
}
