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
      subnet = "2";
    in {
      networking.nat = {
        enable = true;
        enableIPv6 = true;
        internalInterfaces = [ "ve-+" ];
      };

      services.nginx.virtualHosts."beryllium.lava.moe" = {
        useACMEHost = "lava.moe";
        forceSSL = true;
        locations."/".extraConfig = "return 302 'https://lava.moe';";
        locations."/_matrix".proxyPass = "http://[fd0d:1::${subnet}:2]:6167";
        locations."/_conduwuit".proxyPass = "http://[fd0d:1::${subnet}:2]:6167";
        locations."/_continuwuity".proxyPass = "http://[fd0d:1::${subnet}:2]:6167";
      };

      services.nginx.virtualHosts."lava.moe" = {
        locations."= /.well-known/matrix/server".extraConfig =
          let
            server = { "m.server" = "beryllium.lava.moe:443"; };
          in ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';
        locations."= /.well-known/matrix/client".extraConfig =
          let
            client = {
              "m.homeserver" = { "base_url" = "https://beryllium.lava.moe"; };
              # "m.identity_server" = { "base_url" = "https://vector.im"; };
            };
          in ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON client}';
          '';
      };

      systemd.tmpfiles.rules = [ "d /persist/containers/${name} 755 root users" ];
      containers.${name} = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = "10.30.${subnet}.1";
        localAddress = "10.30.${subnet}.2";
        hostAddress6 = "fd0d:1::${subnet}:1";
        localAddress6 = "fd0d:1::${subnet}:2";
        # privateUsers = "pick";
        nixpkgs = nixpkgs;
        ephemeral = true;
        config = { imports = [ ./configuration.nix ]; };

        bindMounts."persist" = {
          hostPath = "/persist/containers/${name}";
          mountPoint = "/persist";
          isReadOnly = false;
        };
        # flake = "path:" + ./.;
      };
    };
  };
}
