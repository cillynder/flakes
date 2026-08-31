{ config, pkgs, ... }:
let
  fqdn = "alyssum-store.lava.moe";
  port = 5001;
in {
  age.secrets.store_alyssum.file = ../../secrets/store_alyssum.age;
  services.nix-serve = {
    enable = true;
    package = pkgs.nix-serve-ng;
    port = port;
    secretKeyFile = config.age.secrets.store_alyssum.path;
  };

  services.nginx.virtualHosts."${fqdn}" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString port}";
      proxyWebsockets = true;
    };
    extraConfig = ''
      proxy_read_timeout 3600s;
      proxy_send_timeout 3600s;
      keepalive_requests 100000;
      keepalive_timeout 5m;
      http2_max_concurrent_streams 512;
    '';
  };
}
