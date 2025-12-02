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

      ${builtins.readFile ./option.lua}
      ${builtins.readFile ./alias.lua}
      ${builtins.readFile ./keymap.lua}
      ${builtins.readFile ./whitespace.lua}

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

      ## python
      python3
      ruff
      ty

      ## go
      gopls

      ## agnostic
      typos-lsp
      clang

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
