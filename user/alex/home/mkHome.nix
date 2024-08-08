# TODO: move to a more shared/common location
{
  username,
  stateVersion,
  isNixos,
}: {
  home = rec {
    inherit username;
    homeDirectory = "/home/${username}";

    sessionVariables = {
      FLAKE = "${homeDirectory}/.nc";
    };

    inherit stateVersion;
  };

  programs.home-manager.enable = true;
  targets.genericLinux.enable = !isNixos;
}
