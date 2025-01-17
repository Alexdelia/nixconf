{
  config,
  pkgs,
  lib,
  ...
}: let
  screenshot = import ./screenshot.nix {inherit config pkgs;};
  imageEdit = import ./image-edit.nix {inherit config pkgs;};
  passwordGen = import ./password-gen.nix {inherit pkgs;};
in {
  imports = [
    ./docker
  ];

  options.customScript = lib.mkOption {
    description = "custom script I made";

    type = lib.types.attrsOf lib.types.path;

    default = {};
  };

  config = {
    home.packages = [
      (import ./ns.nix {inherit pkgs;})
      (import ./nr.nix {inherit pkgs;})
      screenshot
      imageEdit
      passwordGen
    ];

    customScript = {
      screenshot = "${screenshot}/bin/screenshot";
      imageEdit = "${imageEdit}/bin/image-edit";
      passwordGen = "${passwordGen}/bin/password-gen";
    };
  };
}
