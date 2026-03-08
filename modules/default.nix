{ lib }:
let
  getName = path: lib.removeSuffix ".nix" ( # Strip extension
    lib.last (                              # Gets the last part (filename)
      lib.splitString "/" (                 # Splits the path into components
        builtins.toString path              # Converts the path into a string
      )
    )
  );
  mkAttrsFromPaths = paths: builtins.listToAttrs (
    builtins.map (path: {
      name = getName path;
      value = path;
    }) paths
  );
in {
  options = ./options.nix;
  services = mkAttrsFromPaths [
    ./services/jellyfin.nix
    ./services/nginx.nix
    ./services/postgres.nix
    ./services/sonarr.nix
    ./services/synapse.nix
    ./services/syncthing.nix
    ./services/tmptsync.nix
    ./services/transmission.nix
    ./services/unbound.nix
    ./services/vaultwarden.nix
    ./services/website.nix
  ];
  system = mkAttrsFromPaths [
    ./system/aagl.nix
    ./system/audio.nix
    ./system/base.nix
    ./system/bluetooth.nix
    ./system/ccache.nix
    ./system/corectrl.nix
    ./system/docker.nix
    ./system/flatpak.nix
    ./system/greetd.nix
    ./system/gui.nix
    ./system/home-manager.nix
    ./system/home-manager-stable.nix
    ./system/input.nix
    ./system/kernel.nix
    ./system/nix.nix
    ./system/nix-stable.nix
    ./system/packages.nix
    ./system/printing.nix
    ./system/security.nix
    ./system/snapper.nix
    ./system/virtualisation.nix
    ./system/wireguard.nix
  ];
  user = mkAttrsFromPaths [
    ./user/catppuccin.nix
    ./user/direnv.nix
    ./user/dunst.nix
    ./user/eww.nix
    ./user/git.nix
    ./user/gpg.nix
    ./user/hypridle.nix
    ./user/hyprlock.nix
    ./user/kitty.nix
    ./user/mpv.nix
    ./user/neovim.nix
    ./user/neovim-minimal.nix
    ./user/npm.nix
    ./user/obs.nix
    ./user/rofi.nix
    ./user/sessionVariables.nix
    ./user/spicetify.nix
    ./user/theming.nix
    ./user/xdg.nix
    ./user/zsh.nix
  ];
}
