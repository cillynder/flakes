{ ... }: {
  services.nginx.virtualHosts."muse.lava.moe" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/".return = "404";
    locations."/share/".proxyPass = "https://navia.lava.moe";
  };
  services.nginx.virtualHosts."public-meadow.lava.moe" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/".proxyPass = "http://100.67.2.2";
  };
}
