let
  locale = import ../../../common/locale.nix;
in {
  programs.plasma.configFile.plasma-localerc.Formats =
    {LANG = locale.lang;} // locale.formats;
}
