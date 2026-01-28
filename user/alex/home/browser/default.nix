{
  config,
  pkgs,
  ...
}: {
  dp.browser =
    if !config.targets.genericLinux.enable
    then "${pkgs.brave}/bin/brave"
    else "/usr/bin/brave-browser"; # manual install for sandboxed capabilities
  dm.browser = "brave-browser.desktop";

  imports = [
    ./chromium
  ];
}
