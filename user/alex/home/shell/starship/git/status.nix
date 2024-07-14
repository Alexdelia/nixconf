{lib, ...}: let
  ahead = "[\${count}](dimmed yellow)";
  behind = "[\${count}](bold red)";
in {
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

  stashed = "[](dimmed white)";

  staged = "[󰖌](dimmed yellow)";

  ahead = ahead;
  diverged = "${behind}${ahead}";
  behind = behind;

  deleted = "";
  modified = "";
  untracked = "";
  renamed = "";

  typechanged = "T";
}
