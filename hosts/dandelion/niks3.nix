{ config, inputs, ... }:
let
  configure = name: {
    file = ../../secrets/${name}.age;
    mode = "770";
    owner = "niks3";
    group = "niks3";
  };
in {
  age.secrets."niks3_api_token" = configure "niks3_api_token";
  age.secrets."niks3_signing_key" = configure "niks3_signing_key";
  age.secrets."niks3_s3_access" = configure "niks3_s3_access";
  age.secrets."niks3_s3_secret" = configure "niks3_s3_secret";

  imports = [
    inputs.niks3.nixosModules.niks3
  ];

  services.niks3 = {
    enable = true;
    httpAddr = "127.0.0.1:5751";
    readProxy = {
      enable = true;
      redirectTTL = "25h";
    };

    apiTokenFile = config.age.secrets."niks3_api_token".path;
    signKeyFiles = [ config.age.secrets."niks3_signing_key".path ];

    s3 = {
      accessKeyFile = config.age.secrets."niks3_s3_access".path;
      secretKeyFile = config.age.secrets."niks3_s3_secret".path;

      endpoint = "s3.us-west-004.backblazeb2.com";
      bucket = "lstore-nix";
      region = "us-west-004";
      useSSL = true;
    };

    nginx = {
      enable = true;
      domain = "store.lava.moe";
      enableACME = false;
      forceSSL = true;
    };
  };

  services.nginx.virtualHosts."store.lava.moe" = {
    useACMEHost = "lava.moe";
    listenAddresses = [ "100.67.1.1" ];
    locations."/".extraConfig = ''
      proxy_redirect https://lstore-nix.s3.us-west-004.backblazeb2.com/ https://store.s3-cf.lava.moe/;
      proxy_redirect https://s3.us-west-004.backblazeb2.com/ https://store.s3-cf.lava.moe/;
      proxy_cache_valid 200 24h;
      proxy_cache_valid 404 5m;
    '';
  };
}
