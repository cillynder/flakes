{ config, ... }:
let
  fqdn = "photos.lava.moe";
  shareFqdn = "memo.lava.moe";
in {
  services.immich-public-proxy = {
    enable = true;
    immichUrl = "https://${fqdn}";
  };

  services.nginx.virtualHosts."${shareFqdn}" = {
    useACMEHost = "lava.moe";
    forceSSL = true;

    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.immich-public-proxy.port}";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 50000M;
        proxy_read_timeout   600s;
        proxy_send_timeout   600s;
        send_timeout         600s;
      '';
    };
  };
}
