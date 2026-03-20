{ config, lib, pkgs, ... }:
let
  kblight = "brightnessctl -d ${config.me.kbBacklightDevice}";
in
{
  home.packages = [ config.services.hypridle.package ];
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "${lib.getExe pkgs.playerctl} pause; loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = lib.optionals (config.me.kbBacklightDevice != null) [
        {
          timeout = 120;
          on-timeout = "${kblight} -s && ${kblight} 0";
          on-resume = "${kblight} -r";
        }
      ] ++ [
        {
          timeout = 150;
          on-timeout = "brightnessctl -s && brightnessctl 50%-";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 180;
          on-timeout = "brightnessctl -r && loginctl lock-session";
        }
        {
          timeout = 195;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
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
