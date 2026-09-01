{ config, inputs, ... }: {
  age.secrets."niks3_api_token".file = ../../secrets/niks3_api_token.age;
  age.secrets."niks3_signing_key".file = ../../secrets/niks3_signing_key.age;
  age.secrets."niks3_s3_access".file = ../../secrets/niks3_s3_access.age;
  age.secrets."niks3_s3_secret".file = ../../secrets/niks3_s3_secret.age;

  imports = [
    inputs.niks3.nixosModules.niks3
  ];

  services.niks3 = {
    enable = true;
    httpAddr = "127.0.0.1:5751";
    readProxy = true;
    redirectTTL = "15m";
    publicUrl = "store.s3-cf.lava.moe";

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
    };

    #
    # services.nginx.virtualHosts."cache.example.com".locations."/".extraConfig = ''
    #   proxy_cache_valid 200 24h;
    #   proxy_cache_valid 404 5m;
    # '';
  };
}
