{ config, lib, ... }:
{
  xdg = {
    mimeApps = {
      enable = true;

      defaultApplications = {
        "x-scheme-handler/http" = config.dm.browser;
        "x-scheme-handler/https" = config.dm.browser;
        "text/html" = config.dm.browser;

        "audio/mpeg" = config.dm.browser;

        "video/mp4" = config.dm.browser;
        "video/webm" = config.dm.browser;
      }
      // lib.genAttrs [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/svg+xml"
        "image/webp"
        "image/bmp"
        "image/apng"
        "image/avif"
      ] (_: config.dm.browser);
    };
    configFile."mimeapps.list".force = true;
    dataFile."applications/mimeapps.list".force = true;
  };
}
