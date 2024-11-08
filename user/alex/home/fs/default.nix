{config, ...}: let
  home = config.home.homeDirectory;
in {
  xdg = {
    enable = true;

    cacheHome = "${home}/.cache";
    configHome = "${home}/.config";
    dataHome = "${home}/.local/share";
    stateHome = "${home}/.local/state";

    userDirs = {
      enable = true;

      createDirectories = true;

      extraConfig = {
        XDG_P = "${home}/p";
        XDG_GOINFRE = "${home}/goinfre";
      };

      download = "${home}/Downloads";

      desktop = "${home}/Desktop";

      documents = "${home}/Documents";
      pictures = "${home}/Pictures";
      music = "${home}/Music";
      videos = "${home}/Videos";

      publicShare = "${home}/Public";
      templates = "${home}/Templates";
    };
  };
}
