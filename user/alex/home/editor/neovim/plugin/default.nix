{pkgs}:
with pkgs.vimPlugins; [
  {
    plugin = comment-nvim;
    type = "lua";
    config = "require('Comment').setup()";
  }

  /*
  neodev-nvim
  {
    plugin = nvim-lspconfig;
    type = "lua";
    config = builtins.readFile ./lsp.lua;
  }
  */
]
