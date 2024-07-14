{lib, ...}: {
  programs = {
    starship = {
      enable = true;

      settings = {
        add_newline = false;

        format = lib.concatStrings [
          "$cmd_duration"
          "$status"
          "$memory_usage"
          "$nix_shell"
          "$directory"
          "$git_branch"
          "$git_commit"
          "$git_metrics"
          "$git_state"
          "$git_status"
          "$shlvl"
          " "
        ];

        cmd_duration = import ./cmd_duration.nix;
        status = import ./status.nix;

        memory_usage = import ./memory_usage.nix;

        # TODO: hostname and local ip for ssh

        nix_shell = import ./nix_shell.nix;

        directory = import ./directory.nix;

        git_branch = import ./git/branch.nix;
        git_commit = import ./git/commit.nix;
        git_metrics = import ./git/metrics.nix;
        git_state = import ./git/state.nix;
        git_status = import ./git/status.nix {
          inherit lib;
        };

        shlvl = import ./shlvl.nix;
      };
    };
  };
}
