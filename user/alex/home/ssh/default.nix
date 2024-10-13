{
  pkgs,
  config,
  ...
}: {
  home.packages = [
    (pkgs.writeScriptBin "ssh-fuzzy" (builtins.readFile ./main.sh))
    (pkgs.writers.writeBashBin "ssh-fuzzy-open" {}
      /*
      bash
      */
      ''
        ${config.environment.sessionVariables.XDG_DP_TERMINAL} -e ssh-fuzzy
      '')
  ];
}
