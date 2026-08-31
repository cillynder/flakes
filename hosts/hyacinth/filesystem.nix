{ config, lib, ... }:
let
  mkLabelMount = label: type: {
    device = "/dev/disk/by-label/${label}";
    fsType = type;
    options = [ "defaults" "relatime" ];
  };
  mkBtrfsMount = name: subvol: atime: mkLabelMount name "btrfs" // {
    options = [ "compress=zstd:3" "defaults" "discard=async" "space_cache=v2" "ssd" "subvol=${subvol}" (if atime then "relatime" else "noatime") ];
  };
  mkCakeMount = mkBtrfsMount "CAKE";
in
{
  fileSystems = {
    "/" = {
      device = "rootfs";
      fsType = "tmpfs";
      options = [ "defaults" "size=24G" "mode=755" ];
    };
    "/boot" = mkLabelMount "CUP" "vfat";

    "/mnt/butter" = mkCakeMount "/" true;
    "/mnt/cream" = mkBtrfsMount "CREAM" "/" true;
    "/mnt/cream/permanence/.snapshots" = mkBtrfsMount "CREAM" "/snapshot/permanence" false;
    "/nix" = mkCakeMount "/current/snow" false;
    "/home" = mkCakeMount "/current/home" true;
    "/home/.snapshots" = mkCakeMount "/snapshot/home" false;
    "/root" = mkCakeMount "/current/root" false;
    "/var" = mkCakeMount "/current/var" false;
    "/persist" = {
      depends = [ "/var" ];
      device = "/var/persist";
      fsType = "none";
      options = [ "bind" ];
      neededForBoot = true;
    };
  };
  services.snapper.configs.cream = {
    FSTYPE = "btrfs";
    SUBVOLUME = "/mnt/cream/permanence";
    TIMELINE_CLEANUP = true;
    TIMELINE_CREATE = true;
    TIMELINE_MIN_AGE = "1800";
    TIMELINE_LIMIT_HOURLY = "5";
    TIMELINE_LIMIT_DAILY = "7";
    TIMELINE_LIMIT_WEEKLY = "0";
    TIMELINE_LIMIT_MONTHLY = "0";
    TIMELINE_LIMIT_YEARLY = "0";
  };
  services.beesd.filesystems = {
    cake = {
      spec = "LABEL=CAKE";
      hashTableSizeMB = 1024;
      verbosity = "crit";
      extraOptions = [
        "--loadavg-target" "5.0"
      ];
    };
    cream = {
      spec = "LABEL=CREAM";
      hashTableSizeMB = 1024;
      verbosity = "crit";
      extraOptions = [
        "--loadavg-target" "5.0"
      ];
    };
  };
}
