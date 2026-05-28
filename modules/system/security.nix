{ config, lib, pkgs, ... }: {
  networking.firewall =
  let
    iptables = "${pkgs.iptables}/bin/iptables";
    genCmds = type: ''
      ${iptables} -${type} nixos-fw -p tcp --source 192.168.0.0/16 -j nixos-fw-accept ${if type == "D" then " || true" else ""}
      ${iptables} -${type} nixos-fw -p udp --source 192.168.0.0/16 -j nixos-fw-accept ${if type == "D" then " || true" else ""}
    '';
  in {
    enable = true;
    allowedUDPPortRanges = [ { from = 20000; to = 20100; } ];
    allowedTCPPortRanges = [ { from = 20000; to = 20100; } ];
    trustedInterfaces = [ "wg0" ];
    logRefusedConnections = false;

    extraCommands = genCmds "I";
    extraStopCommands = genCmds "D";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      X11Forwarding = true;
    };

    hostKeys = [
      {
        bits = 4096;
        path = "/persist/ssh_host_rsa_key";
        rounds = 100;
        type = "rsa";
      }
      {
        path = "/persist/ssh_host_ed25519_key";
        rounds = 100;
        type = "ed25519";
      }
    ];
  };

  security = {
    polkit.enable = true;
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
        {
          groups = [ "wheel" ];
          keepEnv = true;
          persist = config.me.environment != "laptop";
        }
      ];
    };
    pam = lib.mkIf (config.me.environment != "headless") {
      u2f = {
        enable = true;
        settings = {
          cue = true;
          pinverification = 1;
        };
      };
      services.doas.rules.auth = {
        u2f.settings.pinverification = lib.mkForce 0;
        u2f_int = lib.mkMerge [
          {
            enable = true;
            order = config.security.pam.services.doas.rules.auth.u2f.order + 1;
            control = "sufficient";
            modulePath = "${pkgs.pam_u2f}/lib/security/pam_u2f.so";
            inherit (config.security.pam.u2f) settings;
          }
          {
            settings = lib.mkForce {
              interactive = true;
              pinverification = 0;
              userpresence = 0;
            };
          }
        ];
      };
    };
  };
}
