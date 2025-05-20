{
  pkgs,
  config,
  scheme,
  ...
}: {
  dp.dmenu = "${pkgs.anyrun}/bin/anyrun";

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
      y.fraction = 1.0 / 5.0;
      width.fraction = width;

      layer = "overlay";

      closeOnClick = true;

      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
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
          	terminal: Some(Terminal(
          		command: "${config.dp.term}"
          		args: "{}"
          	)),
          )
        '';
    };

    # Inline comments are supported for language injection into
    # multi-line strings with Treesitter! (Depends on your editor)
    extraCss = let
      s = (config.scheme or scheme).withHashtag;
    in
      /*
      css
      */
      ''
        * {
        	all: unset;

        	font-size: 3rem;
        	font-family: "SauceCodePro";
        	/* font-weight: bold; */

        	/* transition: 500ms; */
        }

        image {
        	-gtk-icon-transform: scale(3.0);

        	padding: 2rem;
        	margin-right: 1rem;
        }

        #window,
        #match,
        #entry,
        #plugin,
        #main {
        	background: transparent;
        }

        box#main {
        	background: ${s.base00};
        	border-radius: 1.5rem;
        	padding: 1.5rem;
        }

        #entry {
        	background: ${s.base01};
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
        	background: rgba(255, 255, 255, 0.15);
        }
        #match:selected {
        	background: rgba(71, 216, 35, 0.2);
        }
      '';
  };
}
