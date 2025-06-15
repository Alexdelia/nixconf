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
    borders_style: (fg: "#333333"),
    highlight_border_style: (),
    tab_bar: (
        enabled: true,
        active_style: (fg: "#808080", bg: "#111111", modifiers: "Bold"),
        inactive_style: (fg: "#333333", modifiers: "Bold"),
    ),

	progress_bar: (
		symbols: ["█", "", " "],
		track_style: (),
		elapsed_style: (fg: "#333333"),
		thumb_style: (fg: "#333333"),
	),

    scrollbar: (
        symbols: [" ", "█", " ", " "],
        track_style: (),
        ends_style: (),
        thumb_style: (fg: "#333333"),
    ),

	// TODO: add (kind: Property(Widget(ScanStatus)))
    header: (
        rows: [
            (
                left: [
					(
						kind: Text(" "),
						style: (fg: "#333333"),
					),
					(
						kind: Text("󰓃 "),
						style: (fg: "#999999", bg: "#333333", modifiers: "Bold")
					),
					(
						kind: Property(Status(Volume)),
						style: (fg: "#999999", bg: "#333333", modifiers: "Bold")
					),
					(
						kind: Text(""),
						style: (fg: "#333333", modifiers: "Bold")
					),
				],
                center: [
					(
						kind: Property(Status(RandomV2(
							on_label: "", off_label: "",
							on_style: (fg: "#808080", modifiers: "Bold"),
							off_style: (fg: "#333333"),
						))),
					),
					(kind: Text("  ")),
					(
						kind: Property(Status(RepeatV2(
							on_label: "", off_label: "",
							on_style: (fg: "#808080", modifiers: "Bold"),
							off_style: (fg: "#333333"),
						))),
					),
					(kind: Text("  ")),
					(
						kind: Property(Status(ConsumeV2(
							off_label: "󰗶", oneshot_label: "󰻽", on_label: "󰉛",
							off_style: (fg: "#333333"),
							oneshot_style: (fg: "yellow"),
							on_style: (fg: "red"),
						))),
					),
					(kind: Text("  ")),
					(
						kind: Property(Status(SingleV2(
							off_label: "󰖝", oneshot_label: "󱖒", on_label: "󱖐",
							off_style: (fg: "#333333"),
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
                        default: (kind: Text("")),
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
						default: (kind: Text("")),
					),
					(kind: Text(" ")),
				],
			),
			(
				left: [],
				center: [],
				right: [],
			),
			(
				left: [],
				center: [
					(
						kind: Text(""),
						style: (fg: "#333333"),
					),
                    (
						kind: Property(Status(Elapsed)),
						style: (bg: "#333333", modifiers: "Bold"),
					),
                    (
						kind: Property(Status(StateV2(
							playing_label: "█ ",
							paused_label: "🮚 ",
							stopped_label: " ",
						))),
						style: (fg: "#333333", bg: "#1a1a1a"),
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

    highlighted_item_style: (fg: "white", bg: "#212121", modifiers: "Bold"),
    current_item_style: (fg: "white", bg: "#333333", modifiers: "Bold"),

    header_background_color: None,
    show_song_table_header: true,

    song_table_format: [
        (
			label: "  ",
            prop: (
				kind: Property(Artist), style: (modifiers: "Italic"),
                default: (kind: Text(""))
            ),
            width: "25%",
			alignment: Right,
		),
        (
			label: "  󰗴",
            prop: (
				kind: Property(Title), style: (fg: "#bfbfbf", modifiers: "Bold"),
                default: (kind: Text("-"))
            ),
            width: "42%",
        ),
        (
			label: "  󱈤",
            prop: (
				kind: Property(Other("genre")), style: (fg: "dark_gray"),
                default: (kind: Text(""))
            ),
            width: "28%",
        ),
        (
			label: "󰞌  ",
            prop: (
				kind: Property(Duration), style: (fg: "#bfbfbf"),
				default: (kind: Text("-:--"), style: (fg: "#808080")),
            ),
            width: "6",
            alignment: Right,
        ),
    ],

    browser_column_widths: [20, 38, 42],

    browser_song_format: [
        (
            kind: Group([
                (kind: Property(Track)),
                (kind: Text(" ")),
            ])
        ),
        (
            kind: Group([
                (kind: Property(Artist)),
                (kind: Text(" - ")),
                (kind: Property(Title)),
            ]),
            default: (kind: Property(Filename))
        ),
    ],


    default_album_art_path: None,
)
