{ ... }: {
  networking = {
    useDHCP = true;
    wireless.enable = true;

    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    dhcpcd.extraConfig = ''
      interface wlp1s0
      metric 1500
    '';
  };
  me.localAddrs = [ "100.67.2.1" ];
}
