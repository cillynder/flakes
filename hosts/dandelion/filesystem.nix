{ ... }:
let
  bind = src: {
    depends = [ "/nix" ];
    device = src;
    fsType = "none";
    neededForBoot = true;
    options = [ "bind" ];
  };

  mkLabelMount = label: type: {
    device = "/dev/disk/by-label/${label}";
    fsType = type;
    options = [ "defaults" "relatime" ];
  };
  mkBtrfsMount = name: subvol: atime: mkLabelMount name "btrfs" // {
    options = [ "compress=zstd:3" "defaults" "discard=async" "space_cache=v2" "ssd" "subvol=${subvol}" (if atime then "relatime" else "noatime") ];
  };
  submount = mkBtrfsMount "DANDELION";
in {
  fileSystems = {
    "/" = {
      device = "rootfs";
      fsType = "tmpfs";
      options = [ "defaults" "size=6G" "mode=755" ];
    };
    "/boot" = mkLabelMount "UEFI" "vfat";

    "/nix" = submount "/@/nix" false;
    "/persist" = (submount "/@/persist" true) // { neededForBoot = true; };
    "/persist/.snapshots" = submount "/snap/persist" false;
    "/var/log/journal" = bind "/persist/journal";
  };
}
