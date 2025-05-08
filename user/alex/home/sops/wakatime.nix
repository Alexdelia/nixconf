{config, ...}: let
  secret_path = "wakatime/api_key";
  file = ".wakatime.cfg";
in {
  sops = {
    secrets.${secret_path} = {};

    templates.${file} = {
      content = ''
        [settings]
        debug = false
        hidefilenames = false
        ignore =
        	COMMIT_EDITMSG$
        	PULLREQ_EDITMSG$
        	MERGE_MSG$
        	TAG_EDITMSG$

        api_key = ${config.sops.placeholder.${secret_path}}
      '';
      path = "${config.xdg.configHome}/wakatime/${file}";
    };
  };
}
