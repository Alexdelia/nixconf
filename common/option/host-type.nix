{lib, ...}: {
  options.hostType = lib.mkOption {
    description = "what kind of host is this";

    type = lib.types.enum ["full" "lite" "minimal"];

    default = "lite";
  };
}
