let
  locale = import ../common/locale.nix;
in
{
  i18n = {
    defaultLocale = locale.lang;

    extraLocaleSettings = locale.formats // {
      LC_MESSAGES = locale.message;
    };
  };
}
