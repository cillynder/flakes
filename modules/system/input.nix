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
        ids = [ "*" "-3434:0340" ];
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
