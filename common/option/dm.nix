{ lib, ... }: {
  options.dm = lib.mkOption {
    description = "preferred application for mime type";

    type = lib.types.attrsOf lib.types.str;

    default = {
      editor = "vim.desktop";

      browser = "firefox.desktop";
    };
  };
}
