{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.anyrun.homeManagerModules.default
  ];

  programs.anyrun = {
    enable = true;

    config = let
      width = 1.0 / 4.0;
    in {
      hideIcons = false;
      ignoreExclusiveZones = false;
      hidePluginInfo = true;

      showResultsImmediately = false;
      maxEntries = null;

      x.fraction = 1.0 / 2.0;
      y.fraction = (1.0 - width) / 2.0;
      width.fraction = width;

      layer = "overlay";

      closeOnClick = false;

      plugins = with inputs.anyrun.packages.${pkgs.system}; [
        applications
        # ./some_plugin.so
        # "${inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins}/lib/kidex"
      ];
    };

    extraConfigFiles = {
      "applications.ron".text =
        /*
        ron
        */
        ''
          Config(
            desktop_actions: false,
            max_entries: 8,
            terminal: Some("${config.dp.term}"),
          )
        '';
    };

    # Inline comments are supported for language injection into
    # multi-line strings with Treesitter! (Depends on your editor)
    # extraCss = /*css */ ''
    /*
    .some_class {
    */
    /*
    background: red;
    */
    /*
    }
    */
    /*
    '';
    */
  };

  # nix.settings = {
  #   builders-use-substitutes = true;
  #   extra-substituters = [
  #     "https://anyrun.cachix.org"
  #   ];

  #   extra-trusted-public-keys = [
  #     "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
  #   ];
  # };
}
