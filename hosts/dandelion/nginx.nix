{ ... }: {
  services.nginx.virtualHosts."muse.lava.moe" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/".return = "404";
    locations."/share/".proxyPass = "http://[fd0d:2::5:2]:4533";
  };
  services.nginx.virtualHosts."public-meadow.lava.moe" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/".proxyPass = "http://100.67.2.2";
  };
}
