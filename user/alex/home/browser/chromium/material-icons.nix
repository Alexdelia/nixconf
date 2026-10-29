{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.chromium.localExtensions.material-icons = {
    id = "pknjbmepijfoahncaleibaiagmmieecj";
    src = lib.mkDefault pkgs.material-icons-browser-extension;
    inherit (pkgs.material-icons-browser-extension) version;
    keyFile = config.sops.secrets."chromium-extension/material-icons/crx-key".path;
  };
}
