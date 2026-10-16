{
  config,
  pkgs,
  ...
}:
let
  screenshot = import ./screenshot.nix { inherit config pkgs; };
  imageEdit = import ./image-edit.nix { inherit config pkgs; };
in
{
  imports = [ ./satty.nix ];

  home.packages = [
    screenshot
    imageEdit
  ];

  customScript = {
    screenshot = "${screenshot}/bin/screenshot";
    imageEdit = "${imageEdit}/bin/image-edit";
  };
}
