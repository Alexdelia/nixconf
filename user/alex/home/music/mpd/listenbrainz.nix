{config, ...}: {
  services.listenbrainz-mpd = {
    enable = true;

    settings = {
      token_file = "${config.xdg.configHome}/listenbrainz-mpd/token";

      enable_cache = true;
      cache_file = "${config.xdg.cacheHome}/mpd/listenbrainz/submission-cache.sqlite3";
    };
  };
}
