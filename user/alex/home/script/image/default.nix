{
  config,
  pkgs,
  lib,
  ...
}:
let
  screenshot = import ./screenshot.nix { inherit config pkgs; };
  imageEdit = import ./image-edit.nix { inherit config pkgs; };
  withImageEdit = config.hostOption.type != "minimal";
in
{
  imports = [ ./satty.nix ];

  home.packages = [ screenshot ] ++ lib.optional withImageEdit imageEdit;

  customScript = {
    screenshot = "${screenshot}/bin/screenshot";
  }
  // lib.optionalAttrs withImageEdit {
    imageEdit = "${imageEdit}/bin/image-edit";
  };
}
