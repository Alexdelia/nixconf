{pkgs, ...}: {
  programs.neovim = {
    enable = true;

    viAlias = false;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = ''
      -- # option.lua
      ${builtins.readFile ./option.lua}

      -- # alias.lua
      ${builtins.readFile ./alias.lua}

      -- # keymap.lua
      ${builtins.readFile ./keymap.lua}
    '';

    extraPackages = with pkgs; [
      ## lsp
      lua-language-server
    ];

    plugins = import ./plugin {inherit pkgs;};
  };

  # stylix.targets.neovim.enable = false;
}
