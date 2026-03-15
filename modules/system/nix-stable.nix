{ config, lib, pkgs, ... }: {
  nix = {
    package = pkgs.nixVersions.latest;

    settings = rec {
      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://lava.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "lava.cachix.org-1:8lTWI/3IKWHByzzYHZySunMPYs2eAJw2duL+uLZkSy0="
      ];
      trusted-substituters = substituters;
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  nixpkgs.config.allowUnfree = true;
  programs.nh.enable = true;
}
