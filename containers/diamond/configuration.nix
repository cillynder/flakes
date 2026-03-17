{ fqdn, ... }: {
  system.stateVersion = "25.11";
  systemd.tmpfiles.rules = [
    "d /persist/vaultwarden 755 vaultwarden vaultwarden"
  ];
  fileSystems."/var/lib/vaultwarden" = {
    device = "/persist/vaultwarden";
    fsType = "none";
    options = [ "bind" ];
  };
  networking.firewall.allowedTCPPorts = [ 8000 ];
  networking.firewall.allowedUDPPorts = [ 8000 ];

  services.vaultwarden = {
    enable = true;
    domain = fqdn;
  };
}
