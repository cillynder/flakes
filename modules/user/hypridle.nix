{ config, lib, pkgs, sysConfig, ... }:
let
  kblight = "brightnessctl -d ${config.me.kbBacklightDevice}";
  dpmsOn = if sysConfig.programs.hyprland.enable == true
    then "hyprctl dispatch dpms on"
    else "niri msg action power-on-monitors";
  dpmsOff = if sysConfig.programs.hyprland.enable == true
    then "hyprctl dispatch dpms off"
    else "niri msg action power-off-monitors";
in
{
  home.packages = [ config.services.hypridle.package ];
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "${lib.getExe pkgs.playerctl} pause; loginctl lock-session";
        after_sleep_cmd = dpmsOn;
      };

      listener = lib.optionals (config.me.kbBacklightDevice != null) [
        {
          timeout = 120;
          on-timeout = "${kblight} -s && ${kblight} set 0";
          on-resume = "${kblight} -r";
        }
      ] ++ [
        {
          timeout = 150;
          on-timeout = "brightnessctl -s && brightnessctl set $(( $(brightnessctl get) / 2 ))";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 180;
          on-timeout = "brightnessctl -r && loginctl lock-session";
        }
        {
          timeout = 195;
          on-timeout = dpmsOff;
          on-resume = dpmsOn;
        }
      ] ++ lib.optionals (config.me.environment == "laptop") [
        {
          timeout = 600;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
