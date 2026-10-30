{ ... }: {
  networking = {
    useDHCP = true;
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };
  me.localAddrs = [ "100.67.2.1" ];
}
