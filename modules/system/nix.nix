{ config, lib, pkgs, ... }: {
  nix = {
    package = pkgs.nixVersions.latest;

    settings = rec {
      extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://lava.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "lava.cachix.org-1:8lTWI/3IKWHByzzYHZySunMPYs2eAJw2duL+uLZkSy0="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
      trusted-substituters = substituters;
      trusted-users = [ "root" "rin" ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  nixpkgs.config.allowUnfree = true;
  programs.nh.enable = true;
  system.rebuild.enableNg = true;
}
