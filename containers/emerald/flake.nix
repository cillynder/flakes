{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { nixpkgs, ... }:
  let
    name = "emerald";
    fqdn = "navia.lava.moe";
    shareFqdn = "muse.lava.moe";
    subnetId = "5";

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
        locations."/".proxyPass = "http://[${client}]:4533";
        listenAddresses = [ "10.0.0.1" "[fd0d::1]" ];
      };
      services.nginx.virtualHosts."${shareFqdn}" = {
        useACMEHost = "lava.moe";
        forceSSL = true;
        locations."/".return = "404";
        locations."/share/".proxyPass = "http://[${client}]:4533";
      };

      systemd.tmpfiles.rules = [ "d /persist/containers/${name} 755 root users" ];
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
        specialArgs = { inherit fqdn shareFqdn; };

        bindMounts."persist" = {
          hostPath = "/persist/containers/${name}";
          mountPoint = "/persist";
          isReadOnly = false;
        };
        bindMounts."music" = {
          hostPath = "/persist/media/music";
          mountPoint = "/binds/music";
          isReadOnly = true;
        };
        bindMounts."navidrome_env" = {
          hostPath = config.age.secrets.navidrome_env.path;
          mountPoint = "/binds/navidrome_env";
          isReadOnly = true;
        };
        # flake = "path:" + ./.;
      };
    };
  };
}
