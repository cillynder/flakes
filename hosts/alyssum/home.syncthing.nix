{ config, ... }: {
  me.binds."/home/kujira/.config/syncthing" = "kujira/syncthing/config";
  me.binds."/home/kujira/.local/state/syncthing" = "kujira/syncthing/state";

  users.users.kujira = {
    hashedPasswordFile = config.age.secrets.passwd.path;
    isNormalUser = true;
    linger = true;
  };
  home-manager.users.kujira = { ... }: {
    home = {
      username = "kujira";
      homeDirectory = "/home/kujira";
      stateVersion = "26.05";
    };
    services.syncthing = {
      enable = true;
      guiAddress = "[::]:8385";
    };
  };
}
