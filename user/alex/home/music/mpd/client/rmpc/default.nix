{config, ...}: {
  programs.rmpc = {
    enable = config.hostOption.entertainment.music;

    config =
      /*
      ron
      */
      ''
        (
        	volume_step: 1,

        	default_album_art_pathSection: "${./shortcut.png}",

        	select_current_song_on_change: true,
        	center_current_song_on_change: true,

        	search: (
        		case_sensitive: true,
        		mode: Contains,
        		tags: [
        			(value: "any", label: "any"),
        			(value: "genre", label: "tag"),
        			(value: "title", label: "title"),
        			(value: "artist", label: "artist"),
        			(value: "filename", label: "filename"),
        		],
        	),

         	tabs: [
        		(
         			name: "󰮰 ",
         			pane: Split(
         				direction: Horizontal,
         				panes: [
         					(size: "40%", pane: Pane(AlbumArt)),
         					(size: "60%", pane: Pane(Queue)),
         				],
         			),
         		),
        		(
         			name: " ",
         			pane: Pane(Search),
         		),
        		(
         			name: "󰲸 ",
         			pane: Pane(Playlists),
         		),
        		(
         			name: " ",
         			pane: Pane(Directories),
         		),
         	],

        	enable_config_hot_reloadSection: false,
        )
      '';
  };
}
