{pkgs, ...}: {
  dp.browser = "${pkgs.brave}/bin/brave";
  dm.browser = "brave-browser.desktop";

  imports = [
    ./chromium
  ];
}
