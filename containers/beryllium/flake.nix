{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { nixpkgs, ... }: {
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
    nixosModule = { config, ... }:
    let
      name = "beryllium";
      fqdn = "beryllium.qtnet.work";
      livekitFqdn = "livekit.qtnet.work";
      mautrixProxyFqdn = "md-proxy.qtnet.work";
      serverName = "qtnet.work";
      subnet = "2";

      clientIp = "10.30.${subnet}.2";

      ports = {
        continuwuity = 6167;
        livekit = 7880;
        livekitJwt = 7881;
        livekitRtc = 7882;
        livekitStart = 50067;
        livekitEnd = 50167;

        mautrixDiscord = 29334;
      };
    in {
      age.secrets.mautrix_discord_env.file = ../../secrets/mautrix_discord_env.age;

      networking.nat = {
        enable = true;
        enableIPv6 = true;
        internalInterfaces = [ "ve-${name}" ];
      };
      networking.firewall = {
        allowedTCPPorts = [ ports.livekitRtc ];
        allowedUDPPortRanges = [ { from = ports.livekitStart; to = ports.livekitEnd; } ];
      };

      services.nginx.virtualHosts."${fqdn}" = {
        useACMEHost = "qtnet.work";
        forceSSL = true;
        locations."/".extraConfig = "return 302 'https://qtnet.work';";
        locations."/.well-known/matrix".proxyPass = "http://${clientIp}:${toString ports.continuwuity}";
        locations."/_matrix" = {
          proxyPass = "http://${clientIp}:${toString ports.continuwuity}";
          extraConfig = ''
            client_max_body_size 500M;
          '';
        };
        locations."/_conduwuit".proxyPass = "http://${clientIp}:${toString ports.continuwuity}";
        locations."/_continuwuity".proxyPass = "http://${clientIp}:${toString ports.continuwuity}";
      };

      services.nginx.virtualHosts."${serverName}" = {
        useACMEHost = "qtnet.work";
        forceSSL = true;
        locations."= /.well-known/matrix/server".extraConfig =
          let
            server = { "m.server" = "${fqdn}:443"; };
          in ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';
        locations."= /.well-known/matrix/client".extraConfig =
          let
            client = {
              "m.homeserver" = { "base_url" = "https://${fqdn}"; };
              # "m.identity_server" = { "base_url" = "https://vector.im"; };
            };
          in ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON client}';
          '';
      };

      services.nginx.virtualHosts."${livekitFqdn}" = {
        useACMEHost = "qtnet.work";
        forceSSL = true;
        locations."~ ^/(sfu/get|healthz|get_token)" = {
          extraConfig = ''
            proxy_buffering off;
          '';
          proxyPass = "http://${clientIp}:${toString ports.livekitJwt}";
        };
        locations."/" = {
          proxyPass = "http://${clientIp}:${toString ports.livekit}";
          proxyWebsockets = true;
        };
      };

      services.nginx.virtualHosts."${mautrixProxyFqdn}" = {
        useACMEHost = "qtnet.work";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${clientIp}:${toString ports.mautrixDiscord}";
          proxyWebsockets = true;
        };
      };

      systemd.tmpfiles.rules = [ "d /persist/containers/${name} 755 root users" ];
      containers.${name} = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = "10.30.${subnet}.1";
        localAddress = clientIp;
        nixpkgs = nixpkgs;
        ephemeral = true;
        config = { imports = [ ./configuration.nix ]; };
        specialArgs = { inherit ports; };

        bindMounts."persist" = {
          hostPath = "/persist/containers/${name}";
          mountPoint = "/persist";
          isReadOnly = false;
        };

        bindMounts."mautrix_discord_env" = {
          hostPath = config.age.secrets.mautrix_discord_env.path;
          mountPoint = "/binds/mautrix_discord_env";
          isReadOnly = true;
        };
      };
    };
  };
}
