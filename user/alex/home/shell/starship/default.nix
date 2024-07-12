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
          "$git_metrics"
          "$git_state"
          "$git_status"
          " "
        ];

        cmd_duration = import ./cmd_duration.nix;

        directory = import ./directory.nix;

        git_branch = import ./git/branch.nix;
        git_commit = import ./git/commit.nix;
        git_metrics = import ./git/metrics.nix;
        git_state = import ./git/state.nix;
        git_status = import ./git/status.nix;
      };
    };
  };
}
