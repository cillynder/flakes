{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
  };
  outputs = { nixpkgs, catppuccin, ... }:
  let
    modules = [
      ./configuration.nix
      catppuccin.nixosModules.catppuccin
    ];
  in {
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      inherit modules;
    };
    nixosModule = { ... }:
    let
      name = "citrine";
      subnet = "3";
    in {
      # TODO: this is likely dandelion specific
      networking.firewall.extraCommands = ''
        ip6tables -t nat -A PREROUTING -d fd0d::1:1003 -p tcp --dport 22 -j DNAT --to-destination fd0d:1::${subnet}:2
        ip6tables -t nat -A POSTROUTING -d fd0d:1::${subnet}:2 -p tcp --dport 22 -j SNAT --to-source fd0d::1:1003
      '';
      networking.firewall.extraStopCommands = ''
        ip6tables -t nat -D PREROUTING -d fd0d::1:1003 -p tcp --dport 22 -j DNAT --to-destination fd0d:1::${subnet}:2 || true
        ip6tables -t nat -D POSTROUTING -d fd0d:1::${subnet}:2 -p tcp --dport 22 -j SNAT --to-source fd0d::1:1003 || true
      '';

      services.nginx.virtualHosts."garden.lava.moe" = {
        useACMEHost = "lava.moe";
        forceSSL = true;
        locations."/".proxyPass = "http://[fd0d:1::${subnet}:2]:3000";
      };

      systemd.tmpfiles.rules = [ "d /persist/containers/${name} 755 root users" ];
      containers.${name} = {
        autoStart = true;
        privateNetwork = true;
        hostAddress6 = "fd0d:1::${subnet}:1";
        localAddress6 = "fd0d:1::${subnet}:2";
        # privateUsers = "pick";
        nixpkgs = nixpkgs;
        ephemeral = true;
        config = { imports = modules; };

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
