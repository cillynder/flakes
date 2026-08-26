{ config, ... }:
let
  fqdn = "chat.lava.moe";
  port = 9299;
in {
  age.secrets.librechat_env.file = ../../secrets/librechat_env.age;
  age.secrets.meili_key.file = ../../secrets/meili_key.age;
  services.nginx.virtualHosts."${fqdn}" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/".proxyPass = "http://[::1]:${toString port}";
  };
  services.librechat = {
    enable = true;
    enableLocalDB = true;
    credentialsFile = config.age.secrets.librechat_env.path;
    meilisearch.enable = true;

    env = {
      HOST = "127.0.0.1";
      PORT = port;
    };
    settings = {
      version = "1.0.0";
    };
  };
  services.meilisearch.masterKeyFile = config.age.secrets.meili_key.path;
}
