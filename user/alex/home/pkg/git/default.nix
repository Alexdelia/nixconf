# https://nixos.wiki/wiki/git
{pkgs, ...}: {
  home.packages = with pkgs;
    [
      delta
    ]
    ++ (import ./script {inherit pkgs;});

  programs.git = {
    enable = true;

    extraConfig = {
      user = {
        useConfigOnly = true;

        personal = {
          name = "Alexdelia";
          email = "alexandre.delille.57@gmail.com";
        };
        school = {
          name = "adelille";
          email = "adelille@student.42.fr";
        };
        work = {
          name = "Alexandre Delille";
          email = "alexandre@terros.io";
        };
      };

      push.autoSetupRemote = true;
      pull.rebase = false;

      init.defaultBranch = "main";

      # https://github.com/dandavison/delta?tab=readme-ov-file#get-started
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      merge.conflictStyle = "diff3";
      diff.colorMoved = "default";
      delta = {
        dark = true;
        navigate = true;
        tabs = 4;
        line-numbers = true;
      };
    };

    aliases = {
      vommit = "commit";

      identity = "! git-identity";
      id = "! git-identity";
    };
  };
}
