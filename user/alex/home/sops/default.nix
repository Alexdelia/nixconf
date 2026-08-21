{ config, ... }: {
  imports = [
    ./listenbrainz.nix
    ./wakatime.nix

    ./jiruo.nix
    ./forgejo-ui.nix
  ];

  sops = {
    defaultSopsFile = ../../../../secret/alex.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
