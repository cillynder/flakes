{ config, lib, ... }: {
  system.stateVersion = "25.11";
  networking.firewall.allowedTCPPorts = [ 22 3000 ];
  networking.firewall.allowedUDPPorts = [ 22 3000 ];

  systemd.tmpfiles.rules = [
    "L+ /persist/forgejo/custom/templates - - - - ${./templates}"
  ];

  services.forgejo = {
    enable = true;
    lfs.enable = true;
    settings = {
      DEFAULT.APP_NAME = "Garden";
      server = {
        DOMAIN = "garden.lava.moe";
        ROOT_URL = "https://garden.lava.moe/";
        HTTP_PORT = 3000;
        START_SSH_SERVER = true;
        BUILTIN_SSH_SERVER_USER = "git";
        SSH_DOMAIN = "git.lava.moe";
      };
      ui = lib.mkForce {
        DEFAULT_THEME = "catppuccin-maroon-auto";
        THEMES = lib.strings.concatMapStringsSep "," (x: "${x}-auto") [
          "catppuccin-pink"
          "catppuccin-maroon"
          "catppuccin-flamingo"
          "catppuccin-rosewater"
          "forgejo"
          "gitea"
        ];
      };
      api.ENABLE_SWAGGER = false;
      other.SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
      service.DISABLE_REGISTRATION = true;
    };
    stateDir = "/persist/forgejo";
  };

  systemd.services.forgejo.serviceConfig = {
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    PrivateUsers = lib.mkForce false;
  };

  catppuccin.forgejo.enable = true;

  environment.systemPackages = [ config.services.forgejo.package ];
}
