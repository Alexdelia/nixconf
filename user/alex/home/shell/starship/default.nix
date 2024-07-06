{lib, ...}: {
  programs = {
    starship = {
      enable = true;

      settings = {
        add_newline = false;

        format = lib.concatStrings [
          "$cmd_duration"
          "$directory"
        ];

        cmd_duration = import ./cmd_duration.nix;
      };
    };
  };
}
