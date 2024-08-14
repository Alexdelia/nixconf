{pkgs}: with pkgs.vimPlugins; [
  comment-nvim

  {
    plugin = comment-nvim;
    type = "lua";
    config = "require(\"Comment\").setup()";
  }
]
