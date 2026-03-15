{ modules, modulesPath, ... }: {
  networking.hostName = "dandelion";
  system.stateVersion = "23.11";
  time.timeZone = "Australia/Melbourne";

  age.secrets = {
    acme_dns.file = ../../secrets/acme_dns.age;
    wg_dandelion.file = ../../secrets/wg_dandelion.age;
  };

  imports = with modules.system; [
    (modulesPath + "/profiles/qemu-guest.nix")
    home-manager

    base
    kernel
    nix-stable
    packages
    security
    wireguard

    modules.services.banksia
    modules.services.nginx
    modules.services.unbound
    modules.services.website

    ./filesystem.nix
    ./kernel.nix
    ./networking.nix
    ./transmission-container.nix

    ../../users/hana
  ];

  me.environment = "headless";
}
