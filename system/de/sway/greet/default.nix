{
  users,
  ...
}:
let
  mainUser = builtins.elemAt users 0;
in
{
  # imports = [
  #   ./regreet
  # ];

  config = {
    services.getty.autologinUser = mainUser;

    environment.loginShellInit = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        [ -f "$HOME/.profile" ] && . "$HOME/.profile"
        exec sway
      fi
    '';
  };
}
