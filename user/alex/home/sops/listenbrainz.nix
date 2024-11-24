{
  config,
  # username,
  ...
}: {
  sops = {
    secrets."listenbrainz/user_token" = {
      # owner = username;
      path = config.services.listenbrainz-mpd.settings.submission.token_file;
    };
  };
}
