{ config, ... }: {
  system.stateVersion = "25.11";
  networking.firewall.allowedTCPPorts = [ 3000 ];
  networking.firewall.allowedUDPPorts = [ 3000 ];

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
      };
      service.DISABLE_REGISTRATION = true;
    };
    stateDir = "/persist/forgejo";
  };

  environment.systemPackages = [ config.services.forgejo.package ];
}
