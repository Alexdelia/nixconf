{config, ...}: {
  services.mpdris2.enable = config.hostOption.entertainment.music;
}
