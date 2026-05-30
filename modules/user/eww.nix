{ config, lib, pkgs, ... }:
let
  inherit (lib) boolToString defaultTo;
  res = pkgs.stdenvNoCC.mkDerivation {
    pname = "eww-wayland-config";
    version = "1.0.0";
    dontUnpack = true;
    installPhase = ''
      cp -r ${../../res/eww} $out

      substituteInPlace $out/eww.yuck \
        --replace-fail "_BAT_ENABLED_" "${boolToString (config.me.batteryDevice != null)}" \
        --replace-fail "_BAT_PATH_" "${defaultTo "" config.me.batteryDevice}" \
        --replace-fail "_BT_ENABLED_" "${boolToString config.me.hasBluetooth}" \
        --replace-fail "_WIFI_ENABLED_" "${boolToString config.me.hasWifi}"

      substituteInPlace $out/eww.scss \
        --replace-fail "EWW_BACKGROUND" "${config.catppuccin.hexcolors.crust}" \
        --replace-fail "EWW_TEXT" "${config.catppuccin.hexcolors.text}" \
        --replace-fail "EWW_ACCENT" "${config.catppuccin.hexcolors.${config.catppuccin.accent}}"
    '';
  };
in {
  home.packages = with pkgs; [ iw socat ];
  programs.eww = {
    enable = true;
  };
  xdg.configFile."eww".source = res;
}
