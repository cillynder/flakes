{ inputs, pkgs, ... }: let
  pastel = inputs.pastel.packages.${pkgs.system}.default;
in {
  services.nginx.virtualHosts = {
    "cilly.moe" = {
      useACMEHost = "cilly.moe";
      forceSSL = true;
      root = pastel.outPath;
    };
    "cilly.dev" = {
      useACMEHost = "cilly.dev";
      forceSSL = true;
      root = pastel.outPath;
    };
    "lava.moe" = {
      useACMEHost = "lava.moe";
      forceSSL = true;
      root = inputs.website.outPath;
    };
    "cdn.lava.moe" = {
      useACMEHost = "lava.moe";
      forceSSL = true;
      root = "/persist/cdn";
    };
    "_" = {
      default = true;
      addSSL = true;
      # TODO generate this somewhere
      sslCertificate = "/persist/fakeCerts/fake.crt";
      sslCertificateKey = "/persist/fakeCerts/fake.key";
      extraConfig = ''
        return 444;
      '';
    };
  };
}
