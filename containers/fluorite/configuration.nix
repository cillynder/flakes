{ ... }: {
  system.stateVersion = "25.11";
  systemd.tmpfiles.rules = [
    "d /persist/slskd/downloads 755 slskd slskd"
  ];
  fileSystems."/var/lib/slskd" = {
    device = "/persist/slskd";
    fsType = "none";
    options = [ "bind" ];
  };
  fileSystems."/var/lib/tailscale" = {
    device = "/persist/tailscale";
    fsType = "none";
    options = [ "bind" ];
  };
  networking.firewall.allowedTCPPorts = [ 5030 50300 ];
  networking.firewall.allowedUDPPorts = [ 5030 50300 ];

  services.tailscale = {
    enable = true;
    authKeyFile = "/binds/tailscale_auth";
    openFirewall = true;
    interfaceName = "userspace-networking";
    extraDaemonFlags = [ "--socks5-server=localhost:1055" ];
    extraSetFlags = [ "--exit-node=100.67.1.1" ];
    useRoutingFeatures = "client";
  };

  services.slskd = {
    enable = true;
    domain = null;
    environmentFile = "/binds/slskd_env";
    settings = {
      shares.directories = [ "/binds/music/" ];
      connection.proxy = {
        enabled = true;
        address = "localhost";
        port = "1055";
      };
    };
  };
}
