{ ... }: {
  system.stateVersion = "25.11";
  fileSystems."/var/lib/opencloud" = {
    device = "/persist/opencloud";
    fsType = "none";
    options = [ "bind" ];
  };
  networking.firewall.allowedTCPPorts = [ 9200 ];
  networking.firewall.allowedUDPPorts = [ 9200 ];

  services.slskd = {
    enable = true;
    domain = null;
    environmentFile = "/binds/slskd_env";
    settings = {
      shares.directories = [ "/binds/music/" ];
    };
  };
  environment.etc."opencloud-admin-pass".text = ''
    IDM_ADMIN_PASSWORD=supersillysecure
  '';
  services.opencloud = {
    enable = true;
    url = "https://cloud.lava.moe";
    address = "127.0.0.1";
    port = 9200;
    environment = {
      PROXY_TLS = "false";
    };
    environmentFile = "/etc/opencloud-admin-pass";
  };
}
