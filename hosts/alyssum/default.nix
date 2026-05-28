{ inputs, modules, modulesPath, ... }: {
  networking.hostName = "alyssum";
  system.stateVersion = "25.11";
  time.timeZone = "Australia/Melbourne";

  age.secrets = {
    acme_dns.file = ../../secrets/acme_dns.age;
    wpa_conf = {
      file = ../../secrets/wpa_conf.age;
      path = "/etc/wpa_supplicant/imperative.conf";
      symlink = false;
    };
  };

  imports = with modules.system; [
    (modulesPath + "/profiles/qemu-guest.nix")
    home-manager

    base
    kernel
    nix-stable
    packages
    security
    tailscale

    modules.services.nginx

    inputs.c-garnet.nixosModule

    ./filesystem.nix
    ./kernel.nix
    ./networking.nix

    ../../users/hana
  ];

  me.environment = "headless";
}
