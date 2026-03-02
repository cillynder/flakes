{ config, ... }: {
  networking = {
    #nameservers = [ "8.8.8.8" "8.8.4.4" ];

    #wg-quick.interfaces.wg0.configFile = "/persist/vpn.conf";
    wireless.enableHardening = false;

    networkmanager = {
      enable = true;
      #dns = "none";
    };

    extraHosts = ''
      192.168.100.16 hyacinth
    '';
  };

  environment.etc."NetworkManager/system-connections".source = "/persist/nm_system-connections";
}
