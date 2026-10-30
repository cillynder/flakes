{ pkgs, ... }: {
  systemd.tmpfiles.rules = [
    "h /persist/incus_volumes - - - - +C"
  ];
  networking = {
    useNetworkd = true;
    nftables.enable = true;

    # TODO: hardcoded
    bridges.brincus0.interfaces = [ "enp3s0f3u1" ];
    interfaces.br0.useDHCP = true;
  };
  virtualisation = {
    incus = {
      enable = true;
      ui.enable = true;  # Enable web UI
      preseed = {
        networks = [
          {
            name = "incusbr0";
            type = "bridge";
            config = {
              "ipv4.address" = "10.0.100.1/24";
              "ipv4.nat" = "true";
            };
          }
        ];
        storage_pools = [
          {
            name = "btrfs-alyssum";
            driver = "btrfs";
            config = {
              source = "/persist/incus_volumes";
            };
          }
        ];
        profiles = [
          {
            name = "default";
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "btrfs-alyssum";
                type = "disk";
              };
            };
          }
        ];
      };
    };

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMF ];
      };
    };
  };
}
