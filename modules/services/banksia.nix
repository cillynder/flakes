# TODO ^^
{ ... }: {
  services.nginx.virtualHosts = {
    "banksia.lava.moe" = {
      useACMEHost = "lava.moe";
      forceSSL = true;
      locations."/".return = "302 https://github.com/cillynder/Banksia";
      locations."/api".proxyPass = "http://localhost:8080/";
    };
  };
}
