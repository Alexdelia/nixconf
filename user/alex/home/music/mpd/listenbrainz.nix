{ config, pkgs, ... }: {
  services.listenbrainz-mpd = {
    enable = config.hostOption.entertainment.music;
    package = pkgs.unstable.listenbrainz-mpd;

    settings = {
      submission = {
        token_file = "${config.xdg.configHome}/listenbrainz-mpd/token";

        enable_cache = true;
        cache_file = "${config.xdg.cacheHome}/mpd/listenbrainz/submission-cache.sqlite3";
      };
    };
  };
}
