{pkgs, ...}: {
  home.packages = [
    (pkgs.writeScriptBin "ssh-fuzzy" (builtins.readFile ./main.sh))
    (pkgs.writers.writeBashBin "ssh-fuzzy-open" {}
      /*
      bash
      */
      ''
        alacritty -e ssh-fuzzy
      '')
  ];
}
