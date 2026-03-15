{ config, lib, ... }: {
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

  catppuccin.forgejo.enable = true;

  environment.systemPackages = [ config.services.forgejo.package ];
}
