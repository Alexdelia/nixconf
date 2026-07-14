{pkgs, ...}: {
  dp.calculator = "${pkgs.alacritty}/bin/alacritty -o 'font.size=48' -e ${pkgs.numbat}/bin/numbat";

  imports = [
    ./numbat
  ];
}
