{ pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };
  environment.systemPackages = [
    pkgs.docker-compose
  ];
}
