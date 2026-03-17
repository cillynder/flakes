{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { nixpkgs, ... }:
  let
    name = "fluorite";
    fqdn = "fluorite.lava.moe";
    subnetId = "6";

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
      networking.firewall.allowedTCPPorts = [ 50300 ];

      services.nginx.virtualHosts."${fqdn}" = {
        useACMEHost = "lava.moe";
        forceSSL = true;
        locations."/".proxyPass = "http://[${client}]:5030";
        listenAddresses = [ "10.0.0.1" "[fd0d::1]" ];
      };

      systemd.tmpfiles.rules = [
        "d /persist/containers/${name} 755 root users"
        "d /persist/media/music 075 nobody users"
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

        forwardPorts = [
          {
            containerPort = 50300;
            hostPort = 50300;
            protocol = "tcp";
          }
        ];

        bindMounts."persist" = {
          hostPath = "/persist/containers/${name}";
          mountPoint = "/persist";
          isReadOnly = false;
        };
        bindMounts."shared" = {
          hostPath = "/persist/media/music";
          mountPoint = "/binds/shared";
          isReadOnly = true;
        };
        bindMounts."slskd_env" = {
          hostPath = config.age.secrets.slskd_env.path;
          mountPoint = "/binds/slskd_env";
          isReadOnly = true;
        };
        # flake = "path:" + ./.;
      };
    };
  };
}
