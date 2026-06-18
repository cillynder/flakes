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
      # every 30mns
      OnCalendar = "*-*-* *:00,30:00";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-last 24"
      "--keep-hourly 24"
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
  };
}
