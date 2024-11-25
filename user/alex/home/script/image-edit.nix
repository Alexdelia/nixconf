{
  config,
  pkgs,
  ...
}: let
  edit = "${pkgs.swappy}/bin/swappy";
  paste = config.dp.clipboard-paste;
in (
  pkgs.writers.writeBashBin
  "image-edit" {}
  /*
  bash
  */
  ''${paste} | ${edit} -f -''
)
