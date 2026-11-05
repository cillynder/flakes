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
  services.nginx.virtualHosts."tscpp.lava.moe" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://controlplane.tailscale.com";
      extraConfig = ''
        proxy_set_header Host $proxy_host;
        sub_filter 'https://controlplane.tailscale.com' 'https://tscpp.lava.moe';
        sub_filter_once off;
      '';
    };
  };
}
