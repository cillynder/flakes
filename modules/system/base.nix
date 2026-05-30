{ config, inputs, modules, ... }: {
  imports = [ modules.binds modules.options ];

  environment.etc = {
    "machine-id".source = "/persist/machine-id";
    "ssh/ssh_host_rsa_key".source = "/persist/ssh_host_rsa_key";
    "ssh/ssh_host_rsa_key.pub".source = "/persist/ssh_host_rsa_key.pub";
    "ssh/ssh_host_ed25519_key".source = "/persist/ssh_host_ed25519_key";
    "ssh/ssh_host_ed25519_key.pub".source = "/persist/ssh_host_ed25519_key.pub";
  };
  environment.pathsToLink = [ "/share/zsh" ];

  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocales = [ "en_GB.UTF-8/UTF-8" ];

  users.mutableUsers = false;

  system = {
    configurationRevision = inputs.self.rev;
    nixos = rec {
      version = config.system.nixos.release + versionSuffix;
      versionSuffix = "-${config.system.name}.r${builtins.toString inputs.self.revCount}.${inputs.self.shortRev}";
    };
  };
  nix.registry.config.flake = inputs.self;
  nix.registry.shells.flake = inputs.self;
}
