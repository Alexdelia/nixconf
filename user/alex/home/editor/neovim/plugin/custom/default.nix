{lib}: let
  plugins = [
    "quit"
    "delete_backward"
    "open_remote_rev"
  ];
in
  lib.concatStringsSep "\n" (
    map (
      plugin:
        "-- # custom/${plugin}.lua\n" + builtins.readFile ./${plugin}.lua
    )
    plugins
  )
