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

  # config.dp = {
  # term = "${pkgs.alacritty}/bin/alacritty";
  # editor = "${pkgs.vim}/bin/vim";
  # };
}
