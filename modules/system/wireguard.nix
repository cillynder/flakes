{ config, lib, pkgs, gcSecrets, ... }:
let
  port = 51801;
  serverName = "dandelion";
  serverInterface = "enp0s6";
  serverIp = gcSecrets.wireguard.gateway;

  forwarding = {
#    "22727" = [ "10.100.0.3" "7777" ];
  };

  mapForwards = type:
    builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (sport: tuple:
      let
        dest = builtins.head tuple;
        dport = lib.last tuple;
      in ''
        ${pkgs.iptables}/bin/iptables -${type} PREROUTING -t nat -i ${serverInterface} -p tcp --dport ${sport} -j DNAT --to ${dest}:${dport}
        ${pkgs.iptables}/bin/iptables -${type} FORWARD -p tcp -d ${dest} --dport ${dport} -j ACCEPT
      '') forwarding
    );

  clients = {
    hyacinth = {
      publicKey = "6nVhazYdmC15A/nke9VrqIg3sOBVOmqj4GEsyBq7MVo=";
      allowedIPs = [ "10.100.0.3/32" "${gcSecrets.wireguard.ipv6Subnet}:3" "fd0d::3" ];
      interfaces = {
        wg0 = { peers = [ server6OnlyPeer ]; };
        wg1 = { peers = [ serverPeer ]; autostart = false; };
        wg2 = { peers = [ serverLocalOnlyPeer ]; autostart = false; };
      };
    };
    anemone = {
      publicKey = "px5+JNdAmqBvUC++DhiJrUBRAr+BYP6iYVt4sbhPTWY=";
      allowedIPs = [ "10.100.0.4/32" "${gcSecrets.wireguard.ipv6Subnet}:4" "fd0d::4" ];
      interfaces = {
        wg0 = { peers = [ server6OnlyPeer ]; };
        wg1 = { peers = [ serverPeer ]; autostart = false; };
        wg2 = { peers = [ serverLocalOnlyPeer ]; autostart = false; };
      };
    };
    hibiscus = {
      publicKey = "vQ5a2KMrwi7RCRsD0yvog+n35vQYFuvwiPn+W4lbRBw=";
      allowedIPs = [ "10.100.0.5/32" "${gcSecrets.wireguard.ipv6Subnet}:5" "fd0d::5" ];
      interfaces = {
        wg0 = { peers = [ server6OnlyPeer ]; };
        wg1 = { peers = [ serverPeer ]; autostart = false; };
        wg2 = { peers = [ serverLocalOnlyPeer ]; autostart = false; };
      };
    };
    hazel = {
      publicKey = "0zruTndObzHo+b1rbOuTsxCU97epygZycxXS/lgUHUc=";
      allowedIPs = [ "10.100.0.21/32" "${gcSecrets.wireguard.ipv6Subnet}:21" "fd0d::21" ];
      interfaces = {
        wg0 = {
          dns = [ "::1" "127.0.0.1" ];
          peers = [ serverLocalOnlyPeer ];
        };
      };
    };
  };

  clientPeers = builtins.map (client: builtins.removeAttrs client [ "interfaces" ]) (builtins.attrValues clients);
  serverPeerWith = ips: {
    publicKey = "3ugIk2tQZXjAH9/95s63ld2WNUHQrd4Mz5jzbln6oj0=";
    allowedIPs = ips;
    endpoint = "${serverIp}:${toString port}";
    persistentKeepalive = 25;
  };
  serverPeer = serverPeerWith [ "0.0.0.0/0" "::/0" ];
  server6OnlyPeer = serverPeerWith [ "10.100.0.0/24" "::/0" ];
  serverLocalOnlyPeer = serverPeerWith [ "10.100.0.0/24" "fd0d::/16" ];

  serverConfig = {
    nat = {
      enable = true;
      externalInterface = serverInterface;
      internalInterfaces = [ "wg0" ];
    };
    firewall = {
      allowedTCPPorts = (builtins.map (s: lib.strings.toInt s) (builtins.attrNames forwarding));
      allowedUDPPorts = [ port ];
    };

    wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.1/24" "${gcSecrets.wireguard.ipv6Subnet}:1" "fd0d::1" ];
      listenPort = port;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${serverInterface} -j MASQUERADE
        ${mapForwards "A"}
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${serverInterface} -j MASQUERADE
        ${mapForwards "D"}
      '';

      privateKeyFile = config.age.secrets."wg_${serverName}".path;
      peers = clientPeers;
    };
  };

  clientConfig = {
    wg-quick.interfaces =
    let
      client = clients."${config.networking.hostName}";
    in
      builtins.mapAttrs (interface: conf: {
        address = client.allowedIPs;
        dns = [ "fd0d::1" "10.100.0.1" ];
        privateKeyFile = config.age.secrets."wg_${config.networking.hostName}".path;
      } // conf) client.interfaces;
  };
in {
  boot.kernel.sysctl = lib.mkIf (config.networking.hostName == serverName) ({
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.default.forwarding" = true;
  });
  networking =
    lib.mkMerge [
      (lib.mkIf (config.networking.hostName == serverName) serverConfig)
      (lib.mkIf (config.networking.hostName != serverName) clientConfig)
    ];
}
