{
  programs.readline = {
    enable = true;

    bindings = {
      # ctrl + backspace -> delete word backward
      "\\C-h" = "backward-kill-word";
      # ctrl + delete -> delete word forward
      "\\C-d" = "kill-word";

      # ctrl + left -> move word backward
      "\\e[1;5D" = "backward-word";
      # ctrl + right -> move word forward
      "\\e[1;5C" = "forward-word";

      # ctrl + i -> start of line
      "\\C-i" = "beginning-of-line";
      # ctrl + a -> end of line
      "\\C-a" = "end-of-line";
    };
  };
}
