{ ... }: {
  system.stateVersion = "25.11";
  fileSystems."/var/lib/private" = {
    device = "/persist";
    fsType = "none";
    options = [ "bind" ];
  };

  services.matrix-continuwuity = {
    enable = true;
    settings.global = {
      server_name = "lava.moe";
    };
  };
}
