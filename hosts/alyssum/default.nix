{ inputs, modules, modulesPath, ... }: {
  networking.hostName = "alyssum";
  system.stateVersion = "25.11";
  time.timeZone = "Australia/Melbourne";

  age.secrets = {
    # acme_dns.file = ../../secrets/acme_dns.age;
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
}
