{ ... }: {
  services.snapper = {
    cleanupInterval = "1h";
    persistentTimer = true;
    snapshotInterval = "*-*-* *:00,30:00";
    configs.home = {
      FSTYPE = "btrfs";
      SUBVOLUME = "/flower";
      TIMELINE_CLEANUP = true;
      TIMELINE_CREATE = true;
      TIMELINE_MIN_AGE = "86400";
      TIMELINE_LIMIT_HOURLY = "24";
      TIMELINE_LIMIT_DAILY = "7";
      TIMELINE_LIMIT_WEEKLY = "5";
      TIMELINE_LIMIT_MONTHLY = "3";
      TIMELINE_LIMIT_YEARLY = "0";
    };
  };
}
