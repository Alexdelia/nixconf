{
  i18n = {
    defaultLocale = "C";

    extraLocaleSettings = {
      # 31/01/1970 24:59:59
      LC_TIME = "en_SG.UTF-8";
      # 1 234.56
      LC_NUMERIC = "mfe_MU";
      # € 1234,56
      LC_MONETARY = "nl_NL.UTF-8";
      # metric system
      LC_MEASUREMENT = "nl_NL.UTF-8";

      LC_ADDRESS = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";

      LC_NAME = "en_US.UTF-8";

      LC_PAPER = "nl_NL.UTF-8";
    };

    supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_SG.UTF-8/UTF-8"
      "mfe_MU/UTF-8"
      "en_IN/UTF-8"
      "nl_NL.UTF-8/UTF-8"
      "fr_FR.UTF-8/UTF-8"
    ];
  };
}
