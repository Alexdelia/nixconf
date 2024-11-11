{config, ...}: {
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "audio/mpeg" = config.dm.browser;
    };
  };
}
