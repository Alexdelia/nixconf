# {
# config,
# username,
# ...
# }:
{
  sops = {
    secrets."wakatime/api_key" = {
      # owner = username;
      # path = "/home/${username}/test";
    };
    # };
    # templates."test.toml".content = ''
    # [settings]
    # api_key="${config.sops.placeholder.wakatime.api_key}"
    # '';
  };
}
