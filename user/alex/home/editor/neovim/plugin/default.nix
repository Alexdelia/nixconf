{pkgs}:
with pkgs.vimPlugins; [
  ## lsp
  {
    plugin = nvim-lspconfig;
    type = "lua";
    config = builtins.readFile ./lsp.lua;
  }
  neodev-nvim
  # TODO: crates.nvim https://github.com/saecki/crates.nvim

  ## completion
  {
    plugin = nvim-cmp;
    type = "lua";
    config = builtins.readFile ./cmp.lua;
  }
  cmp-nvim-lsp
  cmp-path
  cmp-buffer
  luasnip

  {
    plugin = comment-nvim;
    type = "lua";
    config = "require('Comment').setup()";
  }
]
