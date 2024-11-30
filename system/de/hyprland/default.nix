{users, ...}: {
  programs.hyprland = {
    enable = true;

    xwayland.enable = true;
  };

  services.getty.autologinUser = builtins.elemAt users 0;

  environment.loginShellInit = ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec dbus-launch Hyprland || echo 'oh no!'
    fi
  '';
}
