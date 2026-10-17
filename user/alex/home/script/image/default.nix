{
  config,
  pkgs,
  lib,
  ...
}:
let
  imageEdit = import ./image-edit.nix { inherit config pkgs; };
  withImageEdit = config.hostOption.type != "minimal";
in
{
  imports = [ ./satty.nix ];

  config = lib.mkIf withImageEdit {
    home.packages = [ imageEdit ];

    customScript.imageEdit = "${imageEdit}/bin/image-edit";
  };
}
