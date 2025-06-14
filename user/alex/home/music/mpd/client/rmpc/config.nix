#![enable(implicit_some)]
#![enable(unwrap_newtypes)]
#![enable(unwrap_variant_newtypes)]
(
	theme: Some("alex"),

	enable_mouse: true,

	volume_step: 1,

	default_album_art_pathSection: "${./shortcut.png}",

	select_current_song_on_change: true,
	center_current_song_on_change: true,

 	tabs: [
		(
 			name: "󰮰",
 			pane: Split(
 				direction: Horizontal,
 				panes: [
 					(size: "87", pane: Split(
						direction: Vertical,
						panes: [
							(size: "6", pane: Pane(Header)),
							(size: "1", pane: Pane(ProgressBar)),
							(size: "42", pane: Pane(AlbumArt)),
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

	enable_config_hot_reloadSection: true,
)
