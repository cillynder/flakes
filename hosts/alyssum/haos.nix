{ ... }: {
  services.nginx.virtualHosts."home.lava.moe" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/".proxyPass = "http://meadow.local/";
  };
}
