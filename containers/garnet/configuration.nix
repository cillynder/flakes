{ ... }: {
  system.stateVersion = "25.11";
  fileSystems."/var/lib/opencloud" = {
    device = "/flower/data";
    fsType = "none";
    options = [ "bind" ];
  };
  fileSystems."/etc/opencloud" = {
    device = "/persist/cfg";
    fsType = "none";
    options = [ "bind" ];
  };
  # TODO: hardcoded address
  networking.extraHosts = ''
    100.67.2.1 cloud.lava.moe
  '';

  networking.firewall.allowedTCPPorts = [ 9200 ];
  networking.firewall.allowedUDPPorts = [ 9200 ];

  environment.etc."opencloud-admin-pass".text = ''
    IDM_ADMIN_PASSWORD=supersillysecure
  '';
  services.opencloud = {
    enable = true;
    url = "https://cloud.lava.moe";
    address = "10.30.7.2";
    port = 9200;
    environment = {
      PROXY_TLS = "false";
    };
    environmentFile = "/etc/opencloud-admin-pass";
  };
}
