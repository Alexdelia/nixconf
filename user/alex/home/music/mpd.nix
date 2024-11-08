{config, ...}: let
  dataDir = "${config.xdg.dataHome}/mpd";
in {
  services.mpd = {
    enable = true;

    musicDirectory = config.xdg.userDirs.music;
    playlistDirectory = "${config.xdg.userDirs.music}/playlist";

    inherit dataDir;
    dbFile = "${dataDir}/mpd.db";
  };
}
