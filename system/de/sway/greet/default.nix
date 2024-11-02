{users, ...}: {
  # imports = [
  #   ./regreet
  # ];

  services.getty.autologinUser = builtins.elemAt users 0;
}
