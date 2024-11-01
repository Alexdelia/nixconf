{
  pkgs,
  lib,
  ...
}: {
  options.dp = lib.mkOption {
    description = "preferred packages";

    type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
      options = {
        bin = lib.mkOption {type = lib.types.path;};
        name = lib.mkOption {type = lib.types.str;};
      };
    }));

    default = {
      term = {
        bin = "${pkgs.alacritty}/bin/alacritty";
        name = "alacritty";
      };
      editor = {
        bin = "${pkgs.vim}/bin/vim";
        name = "vim";
      };
    };
  };
}
