{
  config,
  pkgs,
  ...
}: let
  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  copy = config.dp.clipboard-copy;
in
  pkgs.writers.writeBashBin
  "screenshot" {}
  /*
  bash
  */
  ''${grim} -g "$(${slurp})" - | ${copy}''
