{ ... }: {
  networking.useDHCP = true;
  networking.interfaces.enp2s0.useDHCP = false;
}
