# TODO ^^
{ ... }: {
  services.nginx.virtualHosts = {
    "banksia.lava.moe" = {
      useACMEHost = "lava.moe";
      forceSSL = true;
      locations."/".return = "302 https://lab.lava.moe/cilly/Banksia";
      locations."/api".proxyPass = "http://localhost:8080/";
    };
  };
}
