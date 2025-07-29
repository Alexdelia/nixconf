{config, ...}: {
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "x-scheme-handler/http" = config.dm.browser;
      "x-scheme-handler/https" = config.dm.browser;
      "text/html" = config.dm.browser;

      "audio/mpeg" = config.dm.browser;

      "video/mp4" = config.dm.browser;
      "video/webm" = config.dm.browser;
    };
  };
}
