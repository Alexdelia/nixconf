{pkgs, ...}: {
  home.packages = [
    (pkgs.writeScriptBin "ssh-fuzzy" (builtins.readFile ./main.sh))
    # TODO: do not hard code `alacritty`
    (pkgs.writers.writeBashBin "ssh-fuzzy-open" {}
      /*
      bash
      */
      ''
        alacritty -e ssh-fuzzy
      '')
  ];
}
