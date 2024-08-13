{username}: {pkgs, ...}: {
  users.users.${username} = {
    isNormalUser = true;
    description = "Alexandre Delille";
    extraGroups = ["networkmanager" "wheel" "input" "uinput"];

    # ignoreShellProgramCheck = true;
    shell = pkgs.bash;
  };
}
