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
      proxyWebsockets = true;
      extraConfig = ''
        proxy_pass https://controlplane.tailscale.com;
        proxy_set_header Host "controlplane.tailscale.com";
        sub_filter 'https://controlplane.tailscale.com' 'https://tscpp.lava.moe';
        sub_filter_once off;
      '';
    };
  };
  services.nginx.virtualHosts."proxytest.lava.moe" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    locations."/" = {
      proxyWebsockets = true;
      extraConfig = ''
        proxy_pass https://http-me.glitch.me;
        proxy_set_header Host "http-me.glitch.me";
        sub_filter 'https://controlplane.tailscale.com' 'https://tscpp.lava.moe';
        sub_filter 'https://http-me.glitch.me' 'https://tscpp.lava.moe';
        sub_filter_once off;
      '';
    };
  };
}
