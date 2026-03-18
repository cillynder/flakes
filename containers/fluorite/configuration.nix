{ ... }: {
  system.stateVersion = "25.11";
  systemd.tmpfiles.rules = [
    "d /persist/slskd/Downloads 755 slskd slskd"
  ];
  fileSystems."/var/lib/slskd" = {
    device = "/persist/slskd";
    fsType = "none";
    options = [ "bind" ];
  };
  networking.firewall.allowedTCPPorts = [ 5030 50300 ];
  networking.firewall.allowedUDPPorts = [ 5030 50300 ];

  services.slskd = {
    enable = true;
    domain = null;
    environmentFile = "/binds/slskd_env";
    settings = {
      shares.directories = [ "/binds/music/" ];
    };
  };
}
