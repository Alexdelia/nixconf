{lib, ...}: {
  options.terminal = {
    command = lib.mkOption {
      description = "current terminal emulator binary";
      type = lib.types.path;
    };

    exec = lib.mkOption {
      description = "wrap a command to run in `terminal`, arg: `{command, fontSize ? null}`";
      type = lib.types.functionTo lib.types.str;
    };
  };
}
