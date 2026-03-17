{ inputs, modules, modulesPath, ... }: {
  networking.hostName = "dandelion";
  system.stateVersion = "23.11";
  time.timeZone = "Australia/Melbourne";

  age.secrets = {
    acme_dns.file = ../../secrets/acme_dns.age;
    navidrome_env.file = ../../secrets/navidrome_env.age;
    slskd_env.file = ../../secrets/slskd_env.age;
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

    inputs.c-amethyst.nixosModule
    inputs.c-beryllium.nixosModule
    inputs.c-citrine.nixosModule
    inputs.c-diamond.nixosModule
    inputs.c-emerald.nixosModule
    inputs.c-fluorite.nixosModule

    ./filesystem.nix
    ./kernel.nix
    ./networking.nix

    ../../users/hana
  ];

  me.environment = "headless";
}
