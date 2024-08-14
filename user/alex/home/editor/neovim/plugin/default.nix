{pkgs}: let
  addPlugin = plugin: [
    pkgs.vimPlugins.${plugin}
    (
      {
        plugin = pkgs.vimPlugins.${plugin};
      }
      // (import ./${plugin}.nix)
    )
  ];
in
  addPlugin "comment-nvim"
  ++ addPlugin "nvim-lspconfig"
