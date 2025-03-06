{pkgs, ...}: let
  cmd = "${pkgs.eza}/bin/eza";

  list_node = "--group-directories-first --long --all --no-permissions --no-filesize --no-user --no-time --git";

  list_recursive = "--recurse ${list_node}";
  list_tree = "--tree ${list_node}";

  ignore = "--git-ignore --ignore-glob='.git'";
in {
  l = "${cmd} --long --all --no-permissions --no-filesize --no-user --no-time --git";
  ll = "${cmd} --long --all --group --octal-permissions --header --no-git --group-directories-first";

  lr = "${cmd} ${list_recursive} ${ignore}";
  lt = "${cmd} ${list_tree} ${ignore}";

  lrf = "${cmd} ${list_recursive}";
  ltf = "${cmd} ${list_tree}";
}
