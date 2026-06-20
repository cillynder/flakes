{ config, gcSecrets, ... }:
let
  fqdn = "photos.lava.moe";
  shareFqdn = "memo.lava.moe";
in {
  services.immich = {
    enable = true;
    accelerationDevices = null;
    settings.server.externalDomain = "https://${shareFqdn}";
  };

  me.binds."/var/lib/immich" = "/flower/immich";
  me.binds."/var/lib/immich/encoded-video" = "immich/encoded-video";
  me.binds."/var/lib/immich/profile" = "immich/profile";
  me.binds."/var/lib/immich/thumbs" = "immich/thumbs";
  me.binds."/mnt/immich_external/1/1" = gcSecrets.binds."immich/external/1/1";
  me.binds."/mnt/immich_external/1/2" = gcSecrets.binds."immich/external/1/2";
  hardware.graphics.enable = true;
  users.users.immich.extraGroups = [ "video" "render" ];

  services.nginx.virtualHosts."${fqdn}" = {
    useACMEHost = "lava.moe";
    forceSSL = true;
    listenAddresses = config.me.localAddrs;

    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.immich.port}";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 50000M;
        proxy_read_timeout   600s;
        proxy_send_timeout   600s;
        send_timeout         600s;
      '';
    };
  };
}
