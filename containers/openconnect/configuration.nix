{ inputs, pkgs, ... }: {
  system.stateVersion = "25.11";

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ 123 ];

  fileSystems."/var/lib/tailscale" = {
    device = "/persist";
    fsType = "none";
    options = [ "bind" ];
  };

  services.tailscale = {
    enable = true;
    authKeyFile = "/binds/tailscale_auth";
    openFirewall = true;
    useRoutingFeatures = "both";
  };
  systemd.services.tailscaled.serviceConfig.LogFilterPatterns = [
    "~magicsock.*does not know about peer.*removing route"
  ];
  systemd.network.wait-online.enable = false;

  environment.systemPackages = [
    inputs.openconnect.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
