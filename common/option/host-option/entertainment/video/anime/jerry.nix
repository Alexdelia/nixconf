{
  pkgs,
  config,
  lib,
  scheme ? { },
  ...
}:
let
  menu = import ./jerry-menu.nix {
    pkgs = pkgs.unstable;
    color = (config.scheme or scheme).withHashtag;
    font = {
      inherit (config.stylix.fonts.sansSerif) name;
      size = config.stylix.fonts.sizes.popups;
    };
  };
in
{
  config = lib.mkIf config.hostOption.entertainment.video {
    home.packages = [ pkgs.jerry ];

    xdg.configFile."jerry/jerry.conf".text = lib.toShellVars {
      provider = "zokoanime";
      anime_list_menu = lib.getExe menu;
    };
  };
}
