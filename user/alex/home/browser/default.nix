{
  config,
  pkgs,
  ...
}: {
  dp.browser =
    if !config.targets.genericLinux.enable
    then "${pkgs.brave}/bin/brave"
    else "${pkgs.chromium}/bin/chromium";
  dm.browser =
    if !config.targets.genericLinux.enable
    then "brave-browser.desktop"
    else "chromium-browser.desktop";

  imports = [
    ./chromium
  ];
}
