{lib, ...}: {
  options.hostOption.work = lib.mkOption {
    description = "is this a work machine";

    type = lib.types.bool;

    default = false;
  };
}
