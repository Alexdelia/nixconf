{lib, ...}: {
  format = lib.concatStrings [
    "["

    "( "
    "$stashed"
    "$ahead"
    "$staged"
    ")"

    "( "
    "$deleted"
    "$modified"
    "$untracked"
    "$renamed"
    ")"

    "( "
    "$behind"

    "$diverged"
    "$conflicted"

    "$typechanged"
    ")"

    "]($style)"
  ];
  style = "bold yellow";

  up_to_date = "";

  conflicted = "󱓌";
  diverged = "";

  stashed = "[](dimmed white)";

  staged = "[󰖌](dimmed yellow)";

  ahead = "[⇡](dimmed yellow)";
  behind = "[⇣](bold red)";

  deleted = "";
  modified = "";
  untracked = "";
  renamed = "";

  typechanged = "T";
}
