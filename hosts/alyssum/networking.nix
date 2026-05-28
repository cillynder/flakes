{ config, ... }: {
  networking = {
    useDHCP = true;
    wireless.enable = true;
    wireless.extraConfigFiles = [ config.age.secrets.wpa_conf.path ];

    interfaces.wlp1s0.useDHCP = false;
    interfaces.wlp1s0.ipv4.addresses = [{
      address = "192.168.1.167";
      prefixLength = 24;
    }];

    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };
}
