{
  programs.readline = {
    enable = true;

    variables = {
      completion-ignore-case = true;
      show-all-if-ambiguous = true;
      menu-complete-display-prefix = true;
      colored-stats = true;
      colored-completion-prefix = true;

      blink-matching-paren = true;

      bell-style = false;
      echo-control-characters = false;

      history-ignore-dups = true;
      history-ignore-space = true;
      history-preserve-point = true;
    };

    bindings = {
      # ctrl + backspace -> delete word backward
      "\\C-h" = "backward-kill-word";
      # ctrl + delete -> delete word forward
      "\\C-d" = "kill-word";

      # ctrl + left -> move word backward
      "\\e[1;5D" = "backward-word";
      # ctrl + right -> move word forward
      "\\e[1;5C" = "forward-word";

      # arrow up -> history from most recent
      "\\e[A" = "history-search-backward";
      # arrow down -> history from oldest
      "\\e[B" = "history-search-forward";
    };
  };
}
