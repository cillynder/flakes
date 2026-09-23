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
        after_sleep_cmd = "niri msg action power-on-monitors";
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
          on-timeout = "niri msg action power-off-monitors";
          on-resume = "niri msg action power-on-monitors";
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
