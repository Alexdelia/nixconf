{
  username,
  stateVersion,
  isNixos,
}: {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    inherit stateVersion;
  };

  programs.home-manager.enable = true;
  targets.genericLinux.enable = !isNixos;
}
