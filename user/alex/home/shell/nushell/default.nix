let
  aliases = import./../alias/git.nix;
in
{ programs = {
  nushell = {
    enable = true;

    configFile.source = ./config.nu;
    envFile.source = ./env.nu;

    # builtins.trace aliases;
    # shellAliases = aliases;
  };
};}
