{ config, lib, ... }:
let
  configOn = user: port: {
    me.binds."/home/${user}/.config/syncthing" = "${user}/syncthing/config";
    me.binds."/home/${user}/.local/state/syncthing" = "${user}/syncthing/state";

    systemd.tmpfiles.rules = [ "d /flower/syncthing/${user} 700 ${user} users" ];

    users.users.${user} = {
      hashedPasswordFile = config.age.secrets.passwd.path;
      isNormalUser = true;
      linger = true;
    };
    home-manager.users.${user} = { ... }: {
      home = {
        username = "${user}";
        homeDirectory = "/home/${user}";
        stateVersion = "26.05";
      };
      services.syncthing = {
        enable = true;
        guiAddress = "[::]:${toString port}";
        options.listenAddresses = [
          "tcp://0.0.0.0:2${toString port}"
          "quic://0.0.0.0:2${toString port}"
          "dynamic+https://relays.syncthing.net/endpoint"
        ];
        settings.defaults.folder.path = "/flower/syncthing/${user}";
      };
    };
  };
in lib.mkMerge [
  (configOn "kujira" 8385)
  (configOn "cilly" 8386)
]
