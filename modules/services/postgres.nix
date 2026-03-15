{ config, lib, pkgs, ... }:
let
  dir = "/persist/postgresql/${config.services.postgresql.package.psqlSchema}";
  uid = toString config.ids.uids.postgres;
  gid = toString config.ids.gids.postgres;
in {
  systemd.tmpfiles.rules = [ "d ${dir} 700 ${uid} ${gid}" ];
  services.postgresql = {
    enable = true;
    dataDir = dir;
    # TODO: broken :3
    package = pkgs.postgresql_13;
    authentication = lib.mkOverride 10 ''
      #type  database  DBuser  origin-address      auth-method
      local  all       all                         trust
      host   all       all     127.0.0.1/32        trust
      host   all       all     ::1/128             trust
    '';
  };
}
