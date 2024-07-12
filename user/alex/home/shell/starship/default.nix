{lib, ...}: {
  programs = {
    starship = {
      enable = true;

      settings = {
        add_newline = false;

        format = lib.concatStrings [
          "$cmd_duration"
          "$directory"
          "$git_branch"
          "$git_commit"
          " "
        ];

        cmd_duration = import ./cmd_duration.nix;
        directory = import ./directory.nix;
        git_branch = import ./git_branch.nix;
        git_commit = import ./git_commit.nix;
      };
    };
  };
}
