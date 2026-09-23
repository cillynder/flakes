{ config, lib, sysConfig, ... }:
let
  scaling = if config.me.hidpi then 1 else 0.5;
  s = value: if builtins.isInt value || builtins.isFloat value
  then
    builtins.floor (value * scaling)
  else if builtins.isList value
  then
    lib.strings.concatMapStringsSep "," (v: builtins.toString (scaling * v)) value
  else
    builtins.throw "invalid scaled value type ${builtins.typeOf value} for ${value}";
  sn = value: s (builtins.map (v: (-v)) value);

  monitor = config.me.monitor or "";
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      auth = {
        fingerprint = {
          enabled = config.me.hasFingerprint;
          ready_message = "Scan fingerprint to unlock";
        };
      };
      background = {
        monitor = "";
        path = "${config.home.homeDirectory}/Pictures/Wallpapers/current.png";
        color = "$base";
      };
      shape = lib.optionals (config.me.batteryDevice != null) [
        # Battery pill
        {
          monitor = monitor;
          size = s [180 65];
          color = "$crust";
          rounding = -1;
          halign = "right";
          valign = "top";
          position = sn [710 10];
        }
      ] ++ [
        # Time pill
        {
          monitor = monitor;
          size = s [660 65];
          color = "$crust";
          rounding = -1;
          halign = "right";
          valign = "top";
          position = sn [40 10];
        }
      ];
      label = lib.optionals config.me.hasFingerprint [
        # Fingerprint icon
        {
            monitor = monitor;
            color = "$crust";
            font_family = "Material Symbols Outlined";
            font_size = s 64;
            halign = "center";
            valign = "top";
            position = sn [0 100];
            text = "";
        }
        # Fingerprint text
        {
          monitor = monitor;
          color = "$crust";
          text = "$FPRINTPROMPT";
          font_size = s 25;
          font_family = "Open Sans";
          position = sn [0 235];
          halign = "center";
          valign = "top";
        }
      ] ++ lib.optionals (config.me.batteryDevice != null) [
        # Battery icon
        {
          monitor = monitor;
          text = "";
          color = "$accent";
          font_family = "Material Symbols Outlined";
          font_size = s 27;
          position = sn [825 20];
          halign = "right";
          valign = "top";
        }
        # Battery percentage
        {
          monitor = monitor;
          text = ''cmd[update:60000] echo "<span weight='700'>$(cat /sys/class/power_supply/${config.me.batteryDevice}/capacity)%</span>"'';
          color = "$text";
          font_size = s 23;
          font_family = "Open Sans";
          position = sn [740 20];
          halign = "right";
          valign = "top";
        }
      ] ++ [
        # Time and Date
        {
          monitor = monitor;
          color = "$text";
          font_family = "Open Sans";
          font_size = s 23;
          halign = "right";
          valign = "top";
          position = sn [70 20];
          text = ''cmd[update:1000] echo "<span alpha='70%' weight='550'>$(date '+%A, %d %B %Y')</span>  <span weight='700'>$(date +%H:%M)</span><span alpha='70%' weight='550'>$(date +:%S)</span>"'';
        }

        # Fail text under input
        {
          monitor = monitor;
          color = "$red";
          font_family = "Open Sans";
          font_size = s 25;
          text = "$FAIL $ATTEMPTS[]";
          position = sn [0 200];
          halign = "center";
          valign = "center";
        }
      ];
      input-field = {
        monitor = monitor;
        size = s [600 120];
        outline_thickness = s 4;
        check_color = "$peach";
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        fail_text = "";
        font_color = "$text";
        inner_color = "$crust";
        outer_color = "$base";
        placeholder_text = "Password";
        fade_on_empty = false;
        hide_input = false;
        capslock_color = "$yellow";
        position = sn [0 47];
        halign = "center";
        valign = "center";
      };
    };
  };
}
