{ config, ... }:
let
  dir = "/persist/shared/.syncthing";
  uid = toString config.services.syncthing.user;
  gid = toString config.users.groups.users.gid;
in
{
  systemd.tmpfiles.rules = [
    "d ${dir}/config 700 ${uid} ${gid}"
    "d ${dir}/data 700 ${uid} ${gid}"
  ];
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "rin";
    group = "users";
    dataDir = "/persist/shared/.syncthing/data";
    configDir = "/persist/shared/.syncthing/config";
  };
}
