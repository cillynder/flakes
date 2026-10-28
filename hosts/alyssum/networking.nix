{ config, ... }: {
  networking = {
    useDHCP = true;

    interfaces.enp3s0f3u1.useDHCP = false;
    interfaces.enp3s0f3u1.ipv4.addresses = [{
      address = "192.168.1.167";
      prefixLength = 24;
    }];

    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };
  me.localAddrs = [ "100.67.2.1" ];
}
