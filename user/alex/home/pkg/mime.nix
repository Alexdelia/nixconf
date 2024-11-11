{config, ...}: {
  xdg.mimeApps.defaultApplications = {
    "audio/mpeg" = config.dm.browser;
  };
}
