{
  config,
  pkgs,
  ...
}: let
  screenshot = import ./screenshot.nix {inherit config pkgs;};
  imageEdit = import ./image-edit.nix {inherit config pkgs;};
in {
  home.packages = [
    screenshot
    imageEdit
  ];

  customScript = {
    screenshot = "${screenshot}/bin/screenshot";
    imageEdit = "${imageEdit}/bin/image-edit";
  };
}
