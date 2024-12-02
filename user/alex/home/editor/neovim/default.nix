{
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

      ## rust
      rust-analyzer
      rustc
      cargo
      rustfmt
      clippy

      ## agnostic
      typos-lsp

      ## utils
      fd
    ];

    plugins = import ./plugin {inherit pkgs inputs;};
  };

  xdg.configFile.clangd = {
    enable = true;

    source = ./clangd.yaml;
    target = "clangd/config.yaml";
  };

  # stylix.targets.neovim.enable = false;
}
