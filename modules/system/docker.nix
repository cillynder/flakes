{ pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };
  environment.systemPackages = [
    pkgs.docker-compose
  ];
}
