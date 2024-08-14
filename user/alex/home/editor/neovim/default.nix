{pkgs, ...}: {
  programs.neovim = {
    enable = true;

    viAlias = false;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = ''
      ${builtins.readFile ./option.lua}
    '';

    extraPackages = with pkgs; [
      ## lsp
      lua-language-server
    ];

    plugins = import ./plugin {inherit pkgs;};
  };

  # stylix.targets.neovim.enable = false;
}
