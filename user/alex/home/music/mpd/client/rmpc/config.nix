{ themeName, copyUuid, ... }:
/* ron */ ''
  #![enable(implicit_some)]
  #![enable(unwrap_newtypes)]
  #![enable(unwrap_variant_newtypes)]
  (
  	theme: Some("${themeName}"),

  	enable_mouse: true,

  	volume_step: 1,

  	select_current_song_on_change: true,
  	center_current_song_on_change: true,

   	tabs: [
  		(
   			name: "󰮰",
   			pane: Split(
   				direction: Horizontal,
   				panes: [
   					(size: "100%", pane: Split(
  						direction: Vertical,
  						panes: [
  							(size: "5", pane: Pane(Header)),
  							(size: "1", pane: Pane(ProgressBar)),
  							(size: "100%", pane: Pane(AlbumArt)),
  						],
  					)),
   					(size: "100%", pane: Pane(Queue)),
   				],
   			),
   		),
  		(
   			name: "",
   			pane: Pane(Search),
   		),
  		(
   			name: "󰲸",
   			pane: Pane(Playlists),
   		),
  		(
   			name: "",
   			pane: Pane(Directories),
   		),
   	],

  	search: (
  		case_sensitive: false,
  		mode: Contains,
  		tags: [
  			(value: "any", label: "any"),
  			(value: "genre", label: "tag"),
  			(value: "title", label: "title"),
  			(value: "artist", label: "artist"),
  			(value: "filename", label: "filename"),
  		],
  	),

  	keybinds: (
  		global: {
  			"I": ShowCurrentSongInfo,
  			"y": ExternalCommand(command: ["${copyUuid}", "selected"], description: "copy uuid of selected song"),
  			"Y": ExternalCommand(command: ["${copyUuid}", "current"], description: "copy uuid of playing song"),
  		},
  		navigation: {
  			"i": ShowInfo,
  		},
  	),

  	enable_config_hot_reload: false,
  )
''
