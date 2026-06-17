{ config, lib, ...}: {
  imports = [ ./options.nix ];
  fileSystems = lib.mapAttrs (dest: key: let
    target = if (lib.strings.hasPrefix "/" key)
      then key
      else "/persist/binds/${key}";
  in {
    depends = [ "/persist" ];
    device = target;
    fsType = "none";
    options = [ "bind" ];
  }) config.me.binds;
}
