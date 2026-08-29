{ scheme }:
/* ron */ ''
  #![enable(implicit_some)]
  #![enable(unwrap_newtypes)]
  #![enable(unwrap_variant_newtypes)]
  (
  	text_color: None,
  	background_color: None,
  	modal_background_color: None,

  	symbols: (
  		song: " ",
  		dir: " ",
  		marker: " ",
  		ellipsis: "󰇘"
  	),

  	layout: Split(
  		direction: Vertical,
  		panes: [
  			(
  				pane: Pane(Tabs),
  				size: "1",
  			),
  			(
  				pane: Pane(TabContent),
  				size: "100%",
  			),
  		],
  	),

  	border_type: None,
  	draw_borders: false,
  	borders_style: (fg: "${scheme.base02}"),
  	highlight_border_style: (),
  	tab_bar: (
  		enabled: true,
  		active_style: (fg: "${scheme.base04}", bg: "${scheme.base00}", modifiers: "Bold"),
  		inactive_style: (fg: "${scheme.base02}", modifiers: "Bold"),
  	),

  	progress_bar: (
  		symbols: ["█", "", " "],
  		track_style: (),
  		elapsed_style: (fg: "${scheme.base02}"),
  		thumb_style: (fg: "${scheme.base02}"),
  	),

  	scrollbar: (
  		symbols: [" ", "█", " ", " "],
  		track_style: (),
  		ends_style: (),
  		thumb_style: (fg: "${scheme.base02}"),
  	),

  	// TODO: add (kind: Property(Widget(ScanStatus)))
  	header: (
  		rows: [
  			(
  				left: [
  					(
  						kind: Text(" "),
  						style: (fg: "#1a1a1a"),
  					),
  					(
  						kind: Text("󰓃 "),
  						style: (fg: "${scheme.base04}", bg: "#1a1a1a", modifiers: "Bold")
  					),
  					(
  						kind: Property(Status(Volume)),
  						style: (fg: "${scheme.base04}", bg: "#1a1a1a", modifiers: "Bold")
  					),
  					(
  						kind: Text(""),
  						style: (fg: "#1a1a1a", modifiers: "Bold")
  					),
  				],
  				center: [
  					(
  						kind: Property(Status(RandomV2(
  							on_label: "", off_label: "",
  							on_style: (fg: "${scheme.base04}", modifiers: "Bold"),
  							off_style: (fg: "${scheme.base02}"),
  						))),
  					),
  					(kind: Text("  ")),
  					(
  						kind: Property(Status(RepeatV2(
  							on_label: "", off_label: "",
  							on_style: (fg: "${scheme.base04}", modifiers: "Bold"),
  							off_style: (fg: "${scheme.base02}"),
  						))),
  					),
  					(kind: Text("  ")),
  					(
  						kind: Property(Status(ConsumeV2(
  							off_label: "󰗶", oneshot_label: "󰻽", on_label: "󰉛",
  							off_style: (fg: "${scheme.base02}"),
  							oneshot_style: (fg: "yellow"),
  							on_style: (fg: "red"),
  						))),
  					),
  					(kind: Text("  ")),
  					(
  						kind: Property(Status(SingleV2(
  							off_label: "󰖝", oneshot_label: "󱖒", on_label: "󱖐",
  							off_style: (fg: "${scheme.base02}"),
  							oneshot_style: (fg: "yellow"),
  							on_style: (fg: "#d97f26"),
  						))),
  					),
  				],
  				right: []
  			),
  			(
  				left: [],
  				center: [],
  				right: [],
  			),
  			(
  				left: [
  					(kind: Text(" ")),
  					(
  						kind: Property(Song(Artist)), style: (modifiers: "Italic"),
  						default: None,
  					),
  				],
  				center: [
  					(
  						kind: Property(Song(Title)), style: (modifiers: "Bold"),
  						default: (kind: Text("-"), style: (fg: "dark_gray")),
  					)
  				],
  				right: [
  					(
  						kind: Property(Song(Other("genre"))), style: (fg: "dark_gray"),
  						default: None,
  					),
  					(kind: Text(" ")),
  				],
  			),
  			(
  				left: [
  					(kind: Text(" ")),
  					(
  						kind: Property(Song(Other("artistsort"))), style: (fg: "dark_gray", modifiers: "Italic"),
  						default: None,
  					),
  				],
  				center: [
  					(
  						kind: Property(Song(Other("titlesort"))), style: (fg: "dark_gray"),
  						default: None,
  					)
  				],
  				right: [
  					(kind: Text(" ")),
  				],
  			),
  			(
  				left: [],
  				center: [
  					(
  						kind: Text(""),
  						style: (fg: "${scheme.base02}"),
  					),
  					(
  						kind: Property(Status(Elapsed)),
  						style: (bg: "${scheme.base02}", modifiers: "Bold"),
  					),
  					(
  						kind: Property(Status(StateV2(
  							playing_label: "█ ",
  							paused_label: "🮚 ",
  							stopped_label: " ",
  						))),
  						style: (fg: "${scheme.base02}", bg: "#1a1a1a"),
  					),
  					(
  						kind: Property(Status(Duration)),
  						style: (bg: "#1a1a1a", modifiers: "Bold"),
  					),
  					(
  						kind: Text(""),
  						style: (fg: "#1a1a1a"),
  					),
  				],
  				right: [],
  			),
  		],
  	),

  	highlighted_item_style: (fg: "white", bg: "${scheme.base01}", modifiers: "Bold"),
  	current_item_style: (fg: "white", bg: "${scheme.base02}", modifiers: "Bold"),

  	header_background_color: None,
  	show_song_table_header: true,

  	song_table_format: [
  		(
  			label: "",
  			prop: (
  				kind: Property(Artist), style: (modifiers: "Italic"),
  				default: None,
  			),
  			width: "25%",
  			alignment: Left,
  		),
  		(
  			label: "󰒺",
  			prop: (
  				kind: Property(Other("artistsort")), style: (fg: "dark_gray", modifiers: "Italic"),
  				default: None,
  			),
  			width: "18%",
  		),
  		(
  			label: "󰗴",
  			prop: (
  				kind: Property(Title), style: (fg: "#bfbfbf", modifiers: "Bold"),
  				default: (kind: Text("-"), style: (fg: "${scheme.base04}")),
  			),
  			width: "32%",
  			alignment: Left,
  		),
  		(
  			label: "󰒺",
  			prop: (
  				kind: Property(Other("titlesort")), style: (fg: "dark_gray"),
  				default: None,
  			),
  			width: "18%",
  		),
  		(
  			label: "󰞌  ",
  			prop: (
  				kind: Property(Duration), style: (fg: "#bfbfbf"),
  				default: (kind: Text("-:--"), style: (fg: "${scheme.base04}")),
  			),
  			width: "6",
  			alignment: Right,
  		),
  	],

  	browser_column_widths: [15, 42, 42],

  	browser_song_format: [
  		(
  			kind: Group([
  				(kind: Property(Track)),
  				(kind: Text(" ")),
  			])
  		),
  		(
  			kind: Group([
  				(kind: Property(Artist), style: (modifiers: "Italic")),
  				(kind: Text(" - ")),
  				(kind: Property(Title), style: (fg: "#bfbfbf", modifiers: "Bold")),
  			]),
  			default: (kind: Property(Filename))
  		),
  	],


  	default_album_art_path: None,
  )
''
