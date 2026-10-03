{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.hostOption.entertainment.video {
    home.packages = [ pkgs.jerry ];

    xdg.configFile."jerry/jerry.conf".text = lib.toShellVars {
      provider = "zokoanime";
    };
  };
}
