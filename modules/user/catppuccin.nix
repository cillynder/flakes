{ config, inputs, lib, pkgs, ... }: {
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  options.catppuccin.colors = lib.mkOption {
    type = lib.types.attrs;
    default = (builtins.fromJSON (builtins.readFile "${inputs.catppuccin-palette}/palette.json"))."${config.catppuccin.flavor}".colors;
  };
  options.catppuccin.hexcolors = lib.mkOption {
    type = lib.types.attrs;
    default = builtins.mapAttrs (name: value: value.hex) config.catppuccin.colors;
  };

  config = {
    catppuccin = {
      accent = lib.mkDefault "pink";
      flavor = lib.mkDefault "mocha";
      kitty.enable = true;
      hyprlock.enable = true;
      nvim.enable = true;
    };

    specialisation = {
      light.configuration.catppuccin.flavor = "latte";
      dark.configuration.catppuccin.flavor = "mocha";
    };

    home.packages = [(pkgs.writeShellScriptBin "theme" ''
      last_path="$HOME/.local/state/last-theme"
      target="$1"
      if [ "$target" == "get_last" ]; then
        if [ ! -e "$last_path" ]; then
          echo "no last theme found; assuming dark" >&2
          target="dark"
        else
          target=$(cat "$last_path" | tr -d "\n")
        fi
        echo "$target"
        exit 0
      fi
      if [ "$target" == "restore" ]; then
        echo "restoring theme"
        if [ ! -e "$last_path" ]; then
          echo "no last theme found; assuming dark" >&2
          target="dark"
        else
          target=$(cat "$last_path" | tr -d "\n")
        fi
      fi
      if [ "$target" != "dark" ] && [ "$target" != "light" ]; then
        echo "invalid theme, valid values: [dark, light, restore]"
        exit 1
      fi
      current="$HOME/.local/state/home-manager/gcroots/current-home/"
      cached="$HOME/.local/state/last-parent-specialisation"
      if [ -d "$current/specialisation" ]; then
        if [ -d "$cached" ]; then
          rm -f "$cached"
        fi
        ln -sf "$(readlink -f $current)" "$cached"
      fi

      if [ ! -d "$cached/specialisation" ]; then
        echo "no specialisations found"
        exit 1
      fi

      "$cached/specialisation/$target/activate"

      echo "$target" > "$last_path"
    '')];
  };
}
