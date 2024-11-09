{config, ...}: {
  imports = [
    ./wakatime.nix
  ];

  sops = {
    defaultSopsFile = ../../../../secret/alex.ini;
    defaultSopsFormat = "ini";

    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
