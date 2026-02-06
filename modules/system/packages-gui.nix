{ config, lib, pkgs, ... }: {
  config = lib.mkIf config.me.gui {
    environment.systemPackages = with pkgs; [
      android-tools
      gparted
      nautilus
    ];
    hardware.graphics.extraPackages = with pkgs; [
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
    programs.light.enable = true;
    hardware.opentabletdriver.enable = true;
    hardware.keyboard.qmk.enable = true;
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          gsettings-desktop-schemas
        ];
      };
    };
    services.dbus.packages = [ pkgs.dconf pkgs.gcr ];
    services.gnome.sushi.enable = true;
  };
}
