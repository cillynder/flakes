{ ... }: {
  services.xserver = {
    displayManager = {
      xserverArgs = [
        "-ardelay 150"
        "-arinterval 15"
      ];
    };
  };
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "esc";
            esc = "capslock";
          };
        };
      };
    };
  };
}
