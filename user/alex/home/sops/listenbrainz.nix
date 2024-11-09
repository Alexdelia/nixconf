{
  config,
  # username,
  ...
}: {
  sops = {
    secrets."listenbrainz/user_token" = {
      # owner = username;
      path = config.services.listenbrainz-mpd.settings.token_file;
    };
  };
}
