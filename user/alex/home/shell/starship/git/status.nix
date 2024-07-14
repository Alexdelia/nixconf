{lib, ...}: {
  format = lib.concatStrings [
    "["

    "( "
    "$ahead_behind"
    ")"

    "( "
    "$stashed"
    "$staged"
    ")"

    "( "
    "$deleted"
    "$modified"
    "$untracked"
    "$renamed"
    ")"

    "( "
    "$conflicted"

    "$typechanged"
    ")"

    "]($style)"
  ];
  style = "bold yellow";

  up_to_date = "";

  conflicted = "[󱓌\${count}](bold red)";
  diverged = "";

  stashed = "[](dimmed white)";

  staged = "[󰖌](dimmed yellow)";

  ahead = "[⇡\${count}](dimmed yellow)";
  behind = "[⇣\${count}](bold red)";

  deleted = "";
  modified = "";
  untracked = "";
  renamed = "";

  typechanged = "T";
}
