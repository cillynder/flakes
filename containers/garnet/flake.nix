{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { nixpkgs, ... }:
  let
    name = "garnet";
    fqdn = "cloud.lava.moe";
    subnetId = "7";

    subnet = x: "fd0d:1::${subnetId}:${toString x}";
    host = subnet 1;
    client = subnet 2;

    subnet4 = x: "10.30.${subnetId}.${toString x}";
    host4 = subnet4 1;
    client4 = subnet4 2;

    modules = [
      ./configuration.nix
      {
        networking.useHostResolvConf = false;
        networking.nameservers = [ host ];
      }
    ];
  in {
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      inherit modules;
    };
    nixosModule = { config, ... }: {
      networking.nat = {
        enable = true;
        enableIPv6 = true;
        internalInterfaces = [ "ve-${name}" ];
      };

      services.nginx.virtualHosts."${fqdn}" = {
        useACMEHost = "lava.moe";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${client4}:9200";
          proxyWebsockets = true;
        };
        extraConfig = ''
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
          keepalive_requests 100000;
          keepalive_timeout 5m;
          http2_max_concurrent_streams 512;
        '';
        # TODO: hardcoded address
        listenAddresses = [ "100.67.2.1" ];
      };

      systemd.tmpfiles.rules = [
        "d /persist/containers/${name} 755 root users"
      ];
      containers.${name} = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = host4;
        localAddress = client4;
        hostAddress6 = host;
        localAddress6 = client;
        # privateUsers = "pick";
        nixpkgs = nixpkgs;
        ephemeral = true;
        config = { imports = modules; };
        specialArgs = { inherit fqdn; };

        bindMounts."persist" = {
          hostPath = "/persist/containers/${name}";
          mountPoint = "/persist";
          isReadOnly = false;
        };
        bindMounts."content" = {
          hostPath = "/flower/opencloud";
          mountPoint = "/flower";
          isReadOnly = false;
        };
      };
    };
  };
}
