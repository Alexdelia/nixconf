{
  pkgs,
  config,
  ...
}: let
  name = "ssh-fuzzy";
in {
  home.packages = [
    (pkgs.writeScriptBin name (builtins.readFile ./main.sh))
    (pkgs.writers.writeBashBin "${name}-open" {}
      /*
      bash
      */
      ''
        ${config.dp.term} -e ${name}
      '')
  ];
}
