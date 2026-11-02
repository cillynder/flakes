{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { nixpkgs, ... }: {
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
    nixosModule = { ... }:
    let
      name = "beryllium";
      fqdn = "beryllium.qtnet.work";
      livekitFqdn = "livekit.qtnet.work";
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
      };
    in {
      networking.nat = {
        enable = true;
        enableIPv6 = true;
        internalInterfaces = [ "ve-${name}" ];
      };

      services.nginx.virtualHosts."${fqdn}" = {
        useACMEHost = "qtnet.work";
        forceSSL = true;
        locations."/".extraConfig = "return 302 'https://qtnet.work';";
        locations."/.well-known/matrix".proxyPass = "http://${clientIp}:${ports.continuwuity}";
        locations."/_matrix" = {
          proxyPass = "http://${clientIp}:${ports.continuwuity}";
          extraConfig = ''
            client_max_body_size 500M;
          '';
        };
        locations."/_conduwuit".proxyPass = "http://${clientIp}:${ports.continuwuity}";
        locations."/_continuwuity".proxyPass = "http://${clientIp}:${ports.continuwuity}";
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
      };
    };
  };
}
