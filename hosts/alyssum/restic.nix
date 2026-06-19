{ config, ... }: {
  age.secrets.restic_env.file = ../../secrets/restic_env.age;
  age.secrets.restic_pass.file = ../../secrets/restic_pass.age;
  age.secrets.restic_url.file = ../../secrets/restic_url.age;

  services.restic.backups."flower" = {
    initialize = true;
    createWrapper = true;
    progressFps = 0.016666;

    environmentFile = config.age.secrets.restic_env.path;
    passwordFile = config.age.secrets.restic_pass.path;
    repositoryFile = config.age.secrets.restic_url.path;

    paths = ["/flower"];
    timerConfig = {
      # every 6 hours
      OnCalendar = "*-*-* 00,06,12,18:00:00";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-last 8"
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
  };
}
