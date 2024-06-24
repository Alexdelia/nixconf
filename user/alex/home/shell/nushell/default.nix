let
  aliases = import ../alias;
in
{
  programs = {
  nushell = {
    enable = true;

    configFile.source = ./config.nu;
    envFile.source = ./env.nu;

    shellAliases = aliases;
  };
};}
