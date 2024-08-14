{pkgs, ...}: {
  programs.neovim = {
    enable = true;

    viAlias = false;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = ''
      ${builtins.readFile ./option.lua}
    '';

    plugins = import ./plugin {inherit pkgs;};
  };
}
