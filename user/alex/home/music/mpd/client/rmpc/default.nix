{
  config,
  scheme ? {},
  ...
}: let
  schemeHex = (config.scheme or scheme).withHashtag;
in {
  programs.rmpc = {
    enable = config.hostOption.entertainment.music;

    config = import ./config.nix {scheme = schemeHex;};
  };

  xdg.configFile."rmpc/themes/theme.ron".text = import ./theme.nix {scheme = schemeHex;};
}
