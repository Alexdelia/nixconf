{
  config,
  lib,
  ...
}:
{
  dp.browser =
    if !config.targets.genericLinux.enable then
      lib.getExe config.programs.brave.finalPackage
    else
      "/usr/bin/brave-browser"; # manual install for sandboxed capabilities
  dm.browser =
    if !config.targets.genericLinux.enable then "brave-origin.desktop" else "brave-browser.desktop";

  imports = [
    ./chromium
  ];
}
