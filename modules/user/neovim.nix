{ config, lib, pkgs, ... }:
let
  luaconf = pkgs.writeText "config.lua"
    (lib.replaceStrings
      ["{{OMNISHARP_PATH}}" "{{DART_PATH}}" "{{CATPPUCCIN_FLAVOUR}}"]
      ["${pkgs.omnisharp-roslyn}/bin/OmniSharp" "${pkgs.dart}/bin/dart" config.catppuccin.nvim.flavor]
      (builtins.readFile ../../res/config.lua));
in {
  systemd.user.tmpfiles.rules = [
    "D %t/vim/swap 0755 - - - -"
    "D %t/vim/undo 0755 - - - -"
  ];
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    #package = pkgs.neovim-nightly;
    withNodeJs = true;

    extraPackages = with pkgs; [
      rust-analyzer
      texlab
      astro-language-server
      tailwindcss-language-server
      diagnostic-languageserver
      eslint_d
      typescript-language-server
      vscode-langservers-extracted
      yaml-language-server
    ];

    plugins = with pkgs.vimPlugins; [
      autoclose-nvim
      auto-save-nvim
      flutter-tools-nvim
      fzf-vim
      fzf-lsp-nvim
      lualine-nvim
      nvim-ts-autotag
      nvim-web-devicons
      plenary-nvim
      tokyonight-nvim
      vim-fugitive
      vim-latex-live-preview
      vim-nix
      vim-repeat
      vim-signify
      vim-surround
      vimtex
      lsp_signature-nvim

      nvim-cmp
      nvim-dap
      nvim-highlight-colors
      nvim-lspconfig
      cmp-nvim-lsp
      cmp_luasnip
      luasnip

      #(pkgs.me.nvim-treesitter-nightly.withPlugins (p: with p; [
      (nvim-treesitter.withPlugins (p: with p; [
        tree-sitter-astro
        tree-sitter-bash
        tree-sitter-c
        tree-sitter-c-sharp
        tree-sitter-cpp
        tree-sitter-groovy
        tree-sitter-html
        tree-sitter-java
        tree-sitter-javascript
        tree-sitter-json
        tree-sitter-kotlin
        tree-sitter-latex
        tree-sitter-lua
        tree-sitter-markdown
        tree-sitter-nix
        tree-sitter-php
        tree-sitter-python
        tree-sitter-query
        tree-sitter-regex
        tree-sitter-rust
        tree-sitter-swift
        tree-sitter-toml
        tree-sitter-tsx
        tree-sitter-typescript
        tree-sitter-vim
        tree-sitter-vimdoc
        tree-sitter-xml
        tree-sitter-yaml
      ]))
    ];

    extraConfig = ''
      luafile ${luaconf}
    '';
  };
}
