{ config, lib, pkgs, ... }:
let
  configOn = user: let
    passwd_fname = "passwd_smb${user}";
  in {
    age.secrets.${passwd_fname}.file = ../../secrets/${passwd_fname}.age;
    me.binds."/flower/smb/${user}/syncthing" = "/flower/syncthing/${user}";

    users.users.${user} = {
      hashedPasswordFile = config.age.secrets.passwd.path;
      isNormalUser = true;
    };

    system.activationScripts = {
      init_smbpasswd.text = let
        smbpasswd = "${config.services.samba.package}/bin/smbpasswd";
      in ''
        printf "$(cat ${config.age.secrets.${passwd_fname}.path})\n$(cat ${config.age.secrets.${passwd_fname}.path})\n" | ${smbpasswd} -sa ${user}
      '';
    };
    services.samba.settings."${user}" = {
      "path" = "/flower/smb/${user}";
      "browseable" = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = user;
      "force group" = "users";
      "valid users" = user;
    };
  };
in lib.mkMerge [
  (configOn "cilly")
  (configOn "kujira")
  {
    me.binds."/flower/smb/kujira/opencloud" = "/flower/opencloud/data/storage/users/users/a8e29fc0-673c-4c67-be00-2442904acb43";

    networking.firewall.allowPing = true;

    services.samba = {
      enable = true;
      package = pkgs.samba4Full;
      openFirewall = true;
      settings = {
        global = {
          "server smb encrypt" = "required";
          "workgroup" = "WORKGROUP";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
          "security" = "user";
          "hosts allow" = "100.64.0.0/10 127.0.0.1 alyssum localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        "public" = {
          "path" = "/flower/smb/public";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "hana";
          "force group" = "users";
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    services.avahi = {
      enable = true;
      openFirewall = true;
      nssmdns4 = true;
      publish.enable = true;
      publish.userServices = true;
    };
  }
]
