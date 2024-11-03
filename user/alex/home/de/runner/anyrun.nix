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
      width = 1.0 / 2.0;
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

      closeOnClick = true;

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
            max_entries: 4,
            terminal: Some("${config.dp.term}"),
          )
        '';
    };

    # Inline comments are supported for language injection into
    # multi-line strings with Treesitter! (Depends on your editor)
    extraCss =
      /*
      css
      */
      ''
        * {
        	all: unset;

        	font-size: 3rem;
        	font-family: "SauceCodeProNerdFont";
        	/* font-weight: bold; */

        	/* transition: 500ms; */
        }

        image {
        	-gtk-icon-transform: scale(5.0);
        }

        #window,
        #match,
        #entry,
        #plugin,
        #main {
        	background: transparent;
        }

        box#main {
        	background: rgba(0, 0, 0, 1);
        	border-radius: 1.5rem;
        	padding: 1.5rem;
        }

        #entry {
        	background: rgba(0, 0, 255, 0.1);
        	border-radius: 0.5rem;
        	padding: 1rem;
        }

        #match.activatable {
        	border-radius: 0.5rem;
        	margin: 0.5rem 0;
        	padding: 0.5rem;
        	background: rgba(255, 255, 255, 0.05);
        }
        #match.activatable:first-child {
        	margin-top: 1.5rem;
        }
        #match.activatable:last-child {
        	margin-bottom: 0;
        }

        #match:hover {
        	background: rgba(255, 255, 255, 0.1);
        }
        #match:selected {
        	background: rgba(255, 0, 0, 0.2);
        }
      '';
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
