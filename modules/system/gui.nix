{ config, inputs, lib, pkgs, ... }: {
  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      defaultFonts = {
        serif = [ "NotoSerif" ];
        sansSerif = [ "NotoSans" ];
        monospace = [ "CascadiaCode" ];
      };
    };
    packages = with pkgs; [
      material-symbols
      material-icons
      cascadia-code
      hanazono
      noto-fonts
      noto-fonts-cjk-sans
      open-sans
      twemoji-color-font
      unifont
    ];
  };
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = lib.mkForce false;
    desktopManager.xterm.enable = false;
  };

  environment.systemPackages = [ inputs.niri.packages.x86_64-linux.niri ];
  security.pam.services.hyprlock = {};
}
