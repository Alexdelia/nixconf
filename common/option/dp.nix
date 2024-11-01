{
  pkgs,
  lib,
  ...
}: {
  options.dp = lib.mkOption {
    description = "preferred packages (default packages|program|path)";

    type = lib.types.attrsOf lib.types.path;

    default = {
      term = "${pkgs.alacritty}/bin/alacritty";
      shell = "${pkgs.bash}/bin/bash";
      editor = "${pkgs.vim}/bin/vim";
    };
  };
}
