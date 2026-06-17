{ config, ... }: {
  networking.firewall.allowPing = true;

  users.users.cilly = {
    hashedPasswordFile = config.age.secrets.passwd.path;
    isNormalUser = true;
  };
  users.users.kujira = {
    hashedPasswordFile = config.age.secrets.passwd.path;
    isNormalUser = true;
  };
  system.activationScripts = {
    init_smbpasswd.text = ''
      /run/current-system/sw/bin/printf "$(/run/current-system/sw/bin/cat ${config.age.secrets.passwd.path})\n$(/run/current-system/sw/bin/cat ${config.age.secrets.passwd.path})\n" | /run/current-system/sw/bin/smbpasswd -sa cilly

      /run/current-system/sw/bin/printf "$(/run/current-system/sw/bin/cat ${config.age.secrets.passwd_kujira.path})\n$(/run/current-system/sw/bin/cat ${config.age.secrets.passwd_kujira.path})\n" | /run/current-system/sw/bin/smbpasswd -sa kujira
    '';
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        "hosts allow" = "100.67.2.1 127.0.0.1 localhost";
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
      "cilly" = {
        "path" = "/flower/smb/cilly";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "cilly";
        "force group" = "users";
        "valid users" = "cilly";
      };
      "kujira" = {
        "path" = "/flower/smb/kujira";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "kujira";
        "force group" = "users";
        "valid users" = "kujira";
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
