{ config, pkgs, ... }: {
  networking.firewall.allowPing = true;

  age.secrets.passwd_smbcilly.file = ../../secrets/passwd_smbcilly.age;
  age.secrets.passwd_smbkujira.file = ../../secrets/passwd_smbkujira.age;

  users.users.cilly = {
    hashedPasswordFile = config.age.secrets.passwd.path;
    isNormalUser = true;
  };
  users.users.kujira = {
    hashedPasswordFile = config.age.secrets.passwd.path;
    isNormalUser = true;
  };
  system.activationScripts = {
    init_smbpasswd.text = let
      smbpasswd = "${config.services.samba.package}/bin/smbpasswd";
    in ''
      printf "$(cat ${config.age.secrets.passwd_smbcilly.path})\n$(cat ${config.age.secrets.passwd_smbcilly.path})\n" | ${smbpasswd} -sa cilly

      printf "$(cat ${config.age.secrets.passwd_smbkujira.path})\n$(cat ${config.age.secrets.passwd_smbkujira.path})\n" | ${smbpasswd} -sa kujira
    '';
  };

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
