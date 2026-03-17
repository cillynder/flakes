{ fqdn, shareFqdn, ... }: {
  system.stateVersion = "25.11";
  systemd.tmpfiles.rules = [
    "d /persist/music 755 navidrome navidrome"
    "d /persist/navidrome 755 navidrome navidrome"
  ];
  networking.firewall.allowedTCPPorts = [ 4533 ];
  networking.firewall.allowedUDPPorts = [ 4533 ];

  services.navidrome = {
    enable = true;
    settings = {
      Port = 4533;
      Address = "[::]";
      BaseUrl = "https://${fqdn}/";
      ShareURL = "https://${shareFqdn}";
      EnableSharing = true;
      DataFolder = "/persist/navidrome";
      MusicFolder = "/persist/music";
    };
  };
}
