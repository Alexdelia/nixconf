{
  # dp.infoHub = "eww info_hub";
  dp.infoHub = "eww -c ${./src} info_hub";

  programs.eww = {
    enable = true;

    configDir = ./src;
  };
}
