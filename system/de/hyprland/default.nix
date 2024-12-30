{
  users,
  config,
  lib,
  ...
}: let
  mainUser = builtins.elemAt users 0;
in {
  config = lib.mkIf (config.hostOption.type == "lite") {
    programs.hyprland = {
      enable = true;

      xwayland.enable = true;
    };

    services.getty.autologinUser = mainUser;

    environment.loginShellInit = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ] && [ -L "/home/${mainUser}/.config/hypr/hyprland.conf" ]; then
        exec Hyprland
      fi
    '';
  };
}
