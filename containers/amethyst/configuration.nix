{ lib, pkgs, ... }: {
  system.stateVersion = "23.11";
  systemd.tmpfiles.rules = [
    "d /persist/transmission 755 transmission transmission"
    "d /persist/transmission/.config/transmission-daemon 750 transmission transmission"
    "d /persist/transmission/.incomplete 750 transmission transmission"
    "d /persist/transmission/Downloads 755 transmission transmission"
    "d /persist/transmission/watchdir 755 transmission transmission"
  ];
  networking.wg-quick.interfaces.wg0 = {
    configFile = "/persist/vpn.conf";
    preUp = ''
          # Try to access the DNS for up to 300s
          for i in {1..60}; do
            ${pkgs.iputils}/bin/ping -c1 'google.com' && break
            echo "Attempt $i: DNS still not available"
            sleep 5s
          done
    '';
  };

  # https://github.com/NixOS/nixpkgs/issues/258793
  systemd.services.transmission.serviceConfig = {
    BindReadOnlyPaths = lib.mkForce [ builtins.storeDir "/etc" ];
    RootDirectoryStartOnly = lib.mkForce false;
    RootDirectory = lib.mkForce "";
    PrivateMounts = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
  };

  networking.firewall.allowedTCPPorts = [ 9091 ];
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    downloadDirPermissions = "775";
    openFirewall = true;
    home = "/persist/transmission";
    settings = {
      ratio-limit-enabled = true;
      rpc-bind-address = "0.0.0.0";
      rpc-enabled = true;
      rpc-port = 9091;
      rpc-host-whitelist-enabled = false;
      rpc-whitelist-enabled = false;
    };
  };
}
