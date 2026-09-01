{ config, inputs, pkgs, ... }:
let
  alyssum-sub = if config.networking.hostName == "alyssum" then [] else [
    "https://alyssum-store.lava.moe?priority=1"
  ];
  alyssum-key = if config.networking.hostName == "alyssum" then [] else [
    "alyssum-store.lava.moe-1:MsqKbJYYUfUof3gYFgqTZbJZew2Z49i3U53b8oitvi0="
  ];
in {
  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    package = pkgs.nixVersions.latest;

    settings = rec {
      extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
      substituters = alyssum-sub ++ [
        "https://store.lava.moe?priority=5"
        "https://cache.nixos.org?priority=10"
        "https://lava.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = alyssum-key ++ [
        "store.lava.moe-1:rEUz0+ilezDEaxKoDpjzlD8G3+ZNAeP2rfykatgr0gI="
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
}
