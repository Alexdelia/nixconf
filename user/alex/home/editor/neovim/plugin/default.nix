{pkgs}:
with pkgs.vimPlugins; [
  ## lsp
  {
    plugin = nvim-lspconfig;
    type = "lua";
    config = builtins.readFile ./lsp.lua;
  }
  neodev-nvim

  ## completion
  {
    plugin = nvim-cmp;
    type = "lua";
    config = builtins.readFile ./cmp.lua;
  }
  cmp-nvim-lsp

  {
    plugin = comment-nvim;
    type = "lua";
    config = "require('Comment').setup()";
  }
]
