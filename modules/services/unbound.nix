{ inputs, pkgs, gcSecrets, ... }:
let
  dir = "/persist/unbound";

  converted = pkgs.runCommand "stevenblack-hosts-unbound" {} ''
    echo "server:" > "$out"
    grep '^0\.0\.0\.0' "${inputs.stevenblack-hosts}/hosts" | awk '{print "local-zone: \""$2"\" always_refuse"}' | tail -n +2 >> "$out"
  '';
in {
  networking.firewall.interfaces."ve-+" = {
    allowedUDPPorts = [ 53 853 ];
    allowedTCPPorts = [ 53 853 ];
  };
  networking.firewall.interfaces.wg0 = {
    allowedUDPPorts = [ 53 853 ];
    allowedTCPPorts = [ 53 853 ];
  };
  systemd.tmpfiles.rules = [ "d ${dir} 700 unbound unbound" ];

  services.unbound = {
    enable = true;
    stateDir = dir;
    settings = {
      forward-zone = [{
        name = ".";
        forward-tls-upstream = true;
        forward-addr = [
          "2606:4700:4700::1111@853#cloudflare-dns.com"
          "2606:4700:4700::1001@853#cloudflare-dns.com"
          "1.1.1.1@853#cloudflare-dns.com"
          "1.0.0.1@853#cloudflare-dns.com"
        ];
      }];

      server = {
        interface = [ "0.0.0.0" "::0" ];
        access-control = [
          "127.0.0.1/8      allow"
          "10.0.0.0/8       allow"
          "192.168.100.0/24 allow"
          "fd0d::/16 allow"
          "${gcSecrets.wireguard.ipv6Subnet}:/80 allow"
        ];
        domain-insecure = [ "\"local.lava.moe\"" ];
        local-zone = [ "\"warden.local.lava.moe.\" redirect" ];
        local-data = [
          "\"warden.local.lava.moe. IN A 10.100.0.2\""
        ];
      };

      include = "${converted}";
    };
  };

  systemd.services.unbound.serviceConfig.ReadWritePaths = [ dir ];
}
