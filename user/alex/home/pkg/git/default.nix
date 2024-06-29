# https://nixos.wiki/wiki/git
{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    [
      delta

      (pkgs.writeScriptBin "git-identity" (builtins.readFile ./git-identity.sh))
    ]
    ++ (import ./script {inherit pkgs;});

  programs.git = {
    enable = true;

    extraConfig = {
      user.useConfigOnly = true;

      user.personal.name = "Alexdelia";
      user.personal.email = "alexandre.delille.57@gmail.com";

      user.school.name = "adelille";
      user.school.email = "adelille@student.42.fr";

      user.work.name = "Alexandre Delille";
      user.work.email = "alexandre@terros.io";

      push.autoSetupRemote = true;

      # https://github.com/dandavison/delta?tab=readme-ov-file#get-started
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.navigate = true;
      merge.conflictStyle = "diff3";
      diff.colorMoved = "default";
    };

    aliases = {
      vommit = "commit";

      identity = "! git-identity";
      id = "! git-identity";
    };
  };
}
