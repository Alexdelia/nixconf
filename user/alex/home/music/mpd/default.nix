{config, ...}: let
  dataDir = "${config.xdg.dataHome}/mpd";
in {
  imports = [
    ./listenbrainz.nix
  ];

  services.mpd = {
    enable = true;

    musicDirectory = config.xdg.userDirs.music;
    playlistDirectory = "${config.xdg.userDirs.music}/playlist";

    inherit dataDir;
    dbFile = "${dataDir}/mpd.db";

    extraConfig = ''
      auto_update "yes"

      restore_paused "yes"

      follow_inside_symlinks "yes"
      follow_outside_symlinks "yes"

      audio_output {
      	type "pipewire"
      	name "pipewire"
      }
    '';
  };
}
