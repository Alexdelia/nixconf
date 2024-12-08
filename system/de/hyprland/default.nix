{users, ...}: let
  mainUser = builtins.elemAt users 0;
in {
  programs.hyprland = {
    enable = true;

    xwayland.enable = true;
  };

  services.getty.autologinUser = mainUser;

  environment.loginShellInit = ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ] && [ -L "/home/${mainUser}/.config/hypr/hyprland.conf" ]; then
      exec dbus-launch Hyprland || echo 'oh no!'
    fi
  '';
}
