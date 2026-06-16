{ config, lib, ... }: {
  age.secrets.tailscale_auth.file = ../../secrets/tailscale_auth.age;
  me.binds."/var/lib/tailscale" = "tailscale";
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = lib.mkIf (config.me.environment == "headless") [ 123 ];

  networking.nat = lib.mkIf (config.networking.hostName == "dandelion") {
    enable = true;
    externalInterface = "enp0s6";
    internalInterfaces = [ "tailscaled0" ];
    forwardPorts = [
      {
        sourcePort = 50300;
        proto = "tcp";
        destination = "100.67.2.101:50300";
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [ 50300 ];
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale_auth.path;
    openFirewall = true;
    useRoutingFeatures = if config.me.environment == "headless" then "both" else "client";
  };
}
