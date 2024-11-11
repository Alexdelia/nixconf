{lib, ...}: {
  options.dm = lib.mkOption {
    description = "preferred application for mime type";

    type = lib.types.attrsOf lib.types.path;

    default = {
      browser = "firefox.desktop";
    };
  };
}
