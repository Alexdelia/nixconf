{
  pkgs,
  config,
  ...
}: let
  name = "ssh-fuzzy";

  rg = "${pkgs.ripgrep}/bin/rg";
  sk = "${pkgs.skim}/bin/sk";
in {
  home.packages = [
    (pkgs.writers.writeBashBin name {}
      /*
      bash
      */
      ''
        ssh $(${rg} '^Host\s(.*)' $HOME/.ssh/config -r '$1' | ${sk})
      '')
    (pkgs.writers.writeBashBin "${name}-open" {}
      /*
      bash
      */
      ''
        ${config.dp.term} -e ${name}
      '')
  ];
}
