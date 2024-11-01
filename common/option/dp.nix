{
  pkgs,
  config,
  lib,
  ...
}: {
  # options = with lib;
  # with types; {
  # dp = mkOption {
  # description = "preferred packages";
  #
  # type = attrsOf (submodule ({name, ...}: {
  # options = mkOption {type = path;};
  # }));
  #
  # default = {
  # term = "${pkgs.alacritty}/bin/alacritty";
  # editor = "${pkgs.vim}/bin/vim";
  # };
  # };
  # };

  options.dp = lib.mkOption {
    description = "preferred packages";

    type = lib.attrsOf (lib.submodule ({name, ...}: {
      options = lib.mkOption {type = lib.types.path;};
    }));

    default = {
      term = "${pkgs.alacritty}/bin/alacritty";
      editor = "${pkgs.vim}/bin/vim";
    };
  };

  config.dp = {
    term = "${pkgs.alacritty}/bin/alacritty";
    editor = "${pkgs.vim}/bin/vim";
  };
}
