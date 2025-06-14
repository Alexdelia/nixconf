{config, ...}: {
  programs.rmpc = {
    enable = config.hostOption.entertainment.music;
  };
}
