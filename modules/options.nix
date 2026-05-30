{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    types;
in {
  options.me = {
    environment = mkOption {
      type = types.enum [ "desktop" "laptop" "headless" ];
      default = "desktop";
    };

    hasFingerprint = mkOption {
      type = types.bool;
      default = false;
    };

    gui = mkOption {
      type = types.bool;
      default = config.me.environment != "headless";
    };

    batteryDevice = mkOption {
      type = with types; nullOr (uniq str);
      default = null;
    };

    kbBacklightDevice = mkOption {
      type = with types; nullOr (uniq str);
      default = null;
    };

    hasBluetooth = mkOption {
      type = types.bool;
      default = config.me.environment == "laptop";
    };

    hasWifi = mkOption {
      type = types.bool;
      default = config.me.environment == "laptop";
    };

    hidpi = mkOption {
      type = types.bool;
      default = false;
    };

    binds = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {};
    };
  };
}
