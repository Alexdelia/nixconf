{pkgs, ...}: {
  dp.calculator = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.numbat}/bin/numbat";

  imports = [
    ./numbat
  ];
}
