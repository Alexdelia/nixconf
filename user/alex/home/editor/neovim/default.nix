{pkgs, ...}: {
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

         ${import ./plugin/custom {lib = pkgs.lib;}}
    '';

    extraPackages = with pkgs; [
      ## lsp
      lua-language-server

      fd
    ];

    plugins = import ./plugin {inherit pkgs;};
  };

  # stylix.targets.neovim.enable = false;
}
