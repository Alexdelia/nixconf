{
  users,
  lib,
  config,
  ...
}: let
  mainUser = builtins.elemAt users 0;
in {
  # imports = [
  #   ./regreet
  # ];

  config = lib.mkIf (config.hostOption.type == "minimal" || config.hostOption.type == "lite") {
    services.getty.autologinUser = mainUser;

    environment.loginShellInit = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec dbus-launch sway || echo 'oh no!'
      fi
    '';
  };
}
