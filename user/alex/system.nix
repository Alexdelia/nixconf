{username}: {pkgs, ...}: {
  users.users.${username} = {
    isNormalUser = true;
    description = "Alexandre Delille";
    extraGroups = ["networkmanager" "wheel"];

    ignoreShellProgramCheck = true;
    shell = pkgs.zsh;
  };
}
