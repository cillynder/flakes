{ config, ... }: {
  system.stateVersion = "25.11";
  networking.firewall.allowedTCPPorts = [ 3000 ];
  networking.firewall.allowedUDPPorts = [ 3000 ];

  services.forgejo = {
    enable = true;
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "garden.lava.moe";
        ROOT_URL = "https://garden.lava.moe/";
        HTTP_PORT = 3000;
      };
      service.DISABLE_REGISTRATION = false;
    };
    stateDir = "/persist/forgejo";
  };

  environment.systemPackages = [ config.services.forgejo.package ];
}
