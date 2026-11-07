{ ... }: {
  services.nginx.virtualHosts."muse.lava.moe" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/".return = "404";
    locations."/share/" = {
      extraConfig = ''
        proxy_pass https://navia.lava.moe;
        proxy_set_header Host $proxy_host;
      '';
    };
  };
  services.nginx.virtualHosts."public-meadow.lava.moe" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/".proxyPass = "http://100.67.2.2";
  };
}
