{ inputs, modules, modulesPath, ... }: {
  networking.hostName = "dandelion";
  system.stateVersion = "23.11";
  time.timeZone = "Australia/Melbourne";

  age.secrets = {
    acme_dns.file = ../../secrets/acme_dns.age;
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
    tailscale
    wireguard

    modules.services.banksia
    modules.services.nginx
    modules.services.unbound
    modules.services.website

    inputs.c-amethyst.nixosModule
    inputs.c-beryllium.nixosModule
    inputs.c-citrine.nixosModule
    inputs.c-diamond.nixosModule
    inputs.c-fluorite.nixosModule
    inputs.c-hessonite.nixosModule

    ./filesystem.nix
    ./kernel.nix
    ./immich-proxy.nix
    ./networking.nix
    ./nginx.nix

    ../../users/hana
  ];

  me.environment = "headless";
}
