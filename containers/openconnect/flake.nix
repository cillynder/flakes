{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    openconnect.url = "github:yuezk/GlobalProtect-openconnect";
  };
  outputs = { nixpkgs, ... } @ inputs:
  let
    codename = "hessonite";
    name = "openconnect-router";
    subnetId = "8";

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
      specialArgs = { inherit inputs; };
    };
    nixosModule = { config, ... }: {
      networking.nat = {
        enable = true;
        enableIPv6 = true;
        internalInterfaces = [ "ve-${codename}" ];
      };

      systemd.tmpfiles.rules = [
        "d /persist/containers/${codename} 755 root users"
      ];
      containers.${codename} = {
        autoStart = true;
        privateNetwork = true;
        hostAddress = host4;
        localAddress = client4;
        hostAddress6 = host;
        localAddress6 = client;
        nixpkgs = nixpkgs;
        enableTun = true;
        ephemeral = true;
        specialArgs = { inherit inputs; };
        config = {
          imports = modules;
          networking.hostName = codename;
          networking.domain = config.networking.hostName;
        };

        bindMounts."persist" = {
          hostPath = "/persist/containers/${codename}";
          mountPoint = "/persist";
          isReadOnly = false;
        };

        bindMounts."tailscale_auth" = {
          hostPath = config.age.secrets.tailscale_auth.path;
          mountPoint = "/binds/tailscale_auth";
          isReadOnly = true;
        };
      };
    };
  };
}
