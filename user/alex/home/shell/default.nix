{pkgs, ...}: {
  dp.shell = "${pkgs.bash}/bin/bash";

  imports = [
    ./bash
    # ./zsh
    # ./nushell

    ./starship
  ];
}
