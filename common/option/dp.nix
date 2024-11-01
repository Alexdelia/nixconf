{
  pkgs,
  lib,
  ...
}: {
  options.dp = lib.mkOption {
    description = "preferred packages";

    type = lib.types.attrsOf lib.types.path;

    default = {
      term = "${pkgs.alacritty}/bin/alacritty";
      editor = "${pkgs.vim}/bin/vim";
    };
  };
}
