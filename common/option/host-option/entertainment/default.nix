{lib, ...}: {
  options.hostOption.entertainment = lib.mkOption {
    description = "entertainment options";

    type = lib.types.attrsOf lib.types.bool;

    default = {
      music = true;
      video = false;
      gaming = false;
    };
  };
}
