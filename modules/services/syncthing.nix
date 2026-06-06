{ config, ... }:
let
  dir = "/persist/shared/.syncthing";
  user = if config.me.gui then "rin" else "hana";
  uid = toString config.users.users."${user}".uid;
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
    user = user;
    group = "users";
    dataDir = "/persist/shared/.syncthing/data";
    configDir = "/persist/shared/.syncthing/config";
    guiAddress = if config.me.gui then "127.0.0.1:8384" else ":8384";
  };
}
