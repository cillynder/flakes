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
      name = "amethyst";
      subnet = "1";
    in {
      networking.nat = {
        enable = true;
        enableIPv6 = true;
        internalInterfaces = [ "ve-+" ];
      };

      services.nginx.virtualHosts."amethyst.local.lava.moe" = {
        locations."/".proxyPass = "http://10.30.${subnet}.2:9091";
        listenAddresses = [ "10.0.0.1" "fd0d::1" ];
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
