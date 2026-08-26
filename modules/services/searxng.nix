{ config, ... }:
let
  fqdn = "search.lava.moe";
  port = 9290;
in {
  age.secrets.searx_env.file = ../../secrets/searx_env.age;
  services.nginx.virtualHosts."${fqdn}" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${toString port}";
  };
  services.searx = {
    enable = true;
    redisCreateLocally = true;
    environmentFile = config.age.secrets.searx_env.path;
    settings.server = {
      bind_address = "::1";
      port = port;
    };
    settings.search.formats = ["html" "json"];
  };
}
