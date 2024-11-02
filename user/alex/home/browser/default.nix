{pkgs, ...}: {
  dp.browser = "${pkgs.brave}/bin/brave";

  imports = [
    ./chromium
  ];
}
