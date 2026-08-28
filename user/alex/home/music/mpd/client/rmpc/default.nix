{
  pkgs,
  config,
  scheme ? { },
  ...
}:
let
  themeName = "theme";

  schemeHex = (config.scheme or scheme).withHashtag;

  copyUuid = import ./copy-uuid.nix {
    inherit pkgs;
    rmpc = config.programs.rmpc.package;
    clipboardCopy = config.dp.clipboard-copy;
  };
in
{
  programs.rmpc = {
    enable = config.hostOption.entertainment.music;

    config = import ./config.nix {
      inherit themeName;
      copyUuid = "${copyUuid}/bin/rmpc-copy-uuid";
      scheme = schemeHex;
    };
  };

  xdg.configFile."rmpc/themes/${themeName}.ron".text = import ./theme.nix {
    scheme = schemeHex;
  };
}
