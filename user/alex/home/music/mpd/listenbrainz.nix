{config, ...}: {
  services.listenbrainz-mpd = {
    enable = true;

    settings = {
      # token_file = TODO

      enable_cache = true;
      cache_file = "${config.xdg.cacheHome}/mpd/listenbrainz/submission-cache.sqlite3";
    };
  };
}
