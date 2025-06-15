{
  config,
  scheme ? {},
  ...
}: let
  themeName = "theme";

  schemeHex = (config.scheme or scheme).withHashtag;
in {
  programs.rmpc = {
    enable = config.hostOption.entertainment.music;

    config = import ./config.nix {
      inherit themeName;
      scheme = schemeHex;
    };
  };

  xdg.configFile."rmpc/themes/${themeName}.ron".text = import ./theme.nix {scheme = schemeHex;};
}
