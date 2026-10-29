{ config, ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "me@lava.moe";
      group = "nginx";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      environmentFile = config.age.secrets."acme_dns".path;
    };
    certs."lava.moe" = {
      extraDomainNames = [
        "*.lava.moe"
        "*.local.lava.moe"
      ];
    };
    certs."cilly.moe" = {};
    certs."cilly.dev" = {};
    certs."qtnet.work" = {
      extraDomainNames = [
        "*.qtnet.work"
      ];
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };
}
