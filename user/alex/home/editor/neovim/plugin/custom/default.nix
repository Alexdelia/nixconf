{ lib }:
let
  plugins = [
    "quit"
    "delete_backward"
    "open_remote_rev"
    "run_sql"
  ];
in
plugins
|> map (plugin: "-- # custom/${plugin}.lua\n" + builtins.readFile ./${plugin}.lua)
|> lib.concatStringsSep "\n"
