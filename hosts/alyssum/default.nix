{ lib, modules, modulesPath, ... }: {
  networking.hostName = "alyssum";
  system.stateVersion = "25.11";
  time.timeZone = "Australia/Melbourne";

  age.secrets = {
    wpa_conf.file = ../../secrets/wpa_conf.age;
  };

  imports = with modules.system; [
    (modulesPath + "/profiles/qemu-guest.nix")
    home-manager

    base
    kernel
    nix-stable
    packages
    security

    ./filesystem.nix
    ./kernel.nix
    ./networking.nix

    ../../users/hana
  ];

  me.environment = "headless";

  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
}
