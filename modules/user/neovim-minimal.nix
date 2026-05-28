{ config, lib, pkgs, ... }: {
  systemd.user.tmpfiles.rules = [
    "D %t/vim/swap 0755 - - - -"
    "D %t/vim/undo 0755 - - - -"
  ];
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;

    plugins = with pkgs.vimPlugins; [
      fzf-vim
      lualine-nvim
      tokyonight-nvim
      vim-fugitive
      vim-nix
      vim-repeat
      vim-signify
      vim-surround

      (nvim-treesitter.withPlugins (p: with p; [
        tree-sitter-json
        tree-sitter-lua
        tree-sitter-nix
        tree-sitter-toml
        tree-sitter-yaml
      ]))
    ];

    extraConfig = ''
      luafile ${../../res/config-minimal.lua}
    '';
  };
}
