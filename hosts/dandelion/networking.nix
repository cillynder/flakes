{ ... }: {
  networking.useDHCP = true;
  networking.interfaces.enp2s0.useDHCP = false;
  me.localAddrs = [ "100.67.1.1" ];
}
