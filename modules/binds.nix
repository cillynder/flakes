{ config, lib, ...}: {
  imports = [ ./options.nix ];
  fileSystems = lib.mapAttrs (dest: key: {
    depends = [ "/persist" ];
    device = "/persist/binds/${key}";
    fsType = "none";
    options = [ "bind" ];
  }) config.me.binds;
}
