{lib, ...}: let
  ahead = {
    symbol = "";
    style = "dimmed yellow";
  };
  behind = {
    symbol = "";
    style = "bold red";
  };
in {
  format = lib.concatStrings [
    "["

    "( "
    "$ahead_behind"
    ")"

    "( "
    "$stashed"
    " )"

    "( "
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

  ahead = "[${ahead.symbol}\${count}](${ahead.style})";
  diverged = "[${ahead.symbol}\${ahead_count}](${ahead.style})[${behind.symbol}\${behind_count}](${behind.style})";
  behind = "[${behind.symbol}\${count}](${behind.style})";

  deleted = "";
  modified = "";
  untracked = "";
  renamed = "";

  typechanged = "T";
}
