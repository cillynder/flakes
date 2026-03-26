{ ... }: {
  system.stateVersion = "25.11";
  fileSystems."/var/lib/private" = {
    device = "/persist";
    fsType = "none";
    options = [ "bind" ];
  };
  networking.firewall.allowedTCPPorts = [ 6167 ];
  networking.firewall.allowedUDPPorts = [ 6167 ];
  # TODO: this should be generically set
  networking.useHostResolvConf = false;
  networking.nameservers = [ "8.8.8.8" ];

  services.matrix-continuwuity = {
    enable = true;
    settings.global = {
      # TODO: link this with outer container's address
      address = [ "10.30.2.2" ];
      server_name = "lava.moe";
      rocksdb_recovery_mode = 2;
    };
  };
}
