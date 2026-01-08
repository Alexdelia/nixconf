{
  config,
  inputs,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;

    viAlias = false;
    vimAlias = true;
    vimdiffAlias = true;

    # TODO avoid duplicate
    extraLuaConfig = ''
      -- # early nvim-web-devicons config
      ${builtins.readFile ./plugin/icons.lua}

         -- # option.lua
         ${builtins.readFile ./option.lua}

         -- # alias.lua
         ${builtins.readFile ./alias.lua}

         -- # keymap.lua
         ${builtins.readFile ./keymap.lua}

         ${import ./plugin/custom {inherit (pkgs) lib;}}
    '';

    extraPackages = with pkgs; [
      ## lua
      lua-language-server

      ## nix
      nil
      nixd
      alejandra

      ## rust
      rust-analyzer
      rustc
      cargo
      rustfmt
      clippy

      ## go
      gopls

      ## sql
      postgresql
      # postgres-language-server
      # sqls
      sqruff

      ## bash
      bash-language-server

      ## agnostic
      typos-lsp

      ## utils
      fd
      (
        if config.hostOption.spec.wlroots
        then wl-clipboard-rs
        else wl-clipboard
      )
    ];

    plugins = import ./plugin {inherit pkgs inputs;};
  };

  xdg.configFile.clangd = {
    enable = false;

    source = ./clangd.yaml;
    target = "clangd/config.yaml";
  };

  stylix.targets.neovim.enable = false;
}
