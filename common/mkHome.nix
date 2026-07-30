{
  username,
  stateVersion,
  isNixos,
  hostOption,
}: {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    inherit stateVersion;

    preferXdgDirectories = true;
  };

  # imports = [../common/option];
  inherit hostOption;

  programs.home-manager.enable = true;
  targets.genericLinux.enable = !isNixos;
}
