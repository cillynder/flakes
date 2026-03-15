{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { nixpkgs, ... }: {
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
    nixosModule = { ... }: {
      networking.nat = {
        enable = true;
        enableIPv6 = true;
        internalInterfaces = [ "ve-+" ];
      };

      systemd.tmpfiles.rules = [ "d /persist/containers/amethyst 755 root users" ];
      containers.amethyst = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = "10.30.1.1";
        localAddress = "10.30.1.2";
        hostAddress6 = "fd0d:1::1:1";
        localAddress6 = "fd0d:1::1:2";
        # privateUsers = "pick";
        nixpkgs = nixpkgs;
        ephemeral = true;
        config = { imports = [ ./configuration.nix ]; };

        bindMounts."persist" = {
          hostPath = "/persist/containers/amethyst";
          mountPoint = "/persist";
          isReadOnly = false;
        };
        # flake = "path:" + ./.;
      };
    };
  };
}
