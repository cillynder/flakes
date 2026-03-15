{ config, ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "me@lava.moe";
      group = "nginx";
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets."acme_dns".path;
    };
    certs."lava.moe" = {
      extraDomainNames = [
        "*.lava.moe"
        "*.local.lava.moe"
      ];
    };
    certs."cilly.moe" = {};
    certs."cilly.dev" = {};
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };
}
