{
  pkgs,
  color,
  font,
  maxColumn ? 3,
  maxCoverHeight ? 600,
  pickColumn ? 6,
  pickLine ? 3,
}:
let
  screen = {
    width = 16;
    height = 9;
  };
  cover = {
    width = 230;
    height = 325;
  };

  gap = 20;
  innerGap = gap / 2;
  iconRadius = 12;
  elementRadius = iconRadius + innerGap;
  windowRadius = elementRadius + gap;
  maxEntryWidth =
    maxCoverHeight * screen.height * cover.width / (screen.width * cover.height) + 2 * innerGap;
  maxWindowWidth = maxColumn * maxEntryWidth + (maxColumn + 1) * gap;

  textFont = "${font.name} ${toString (font.size * 36 / 10)}";

  percent = permille: "${toString (permille / 10)}.${toString (pkgs.lib.mod permille 10)}%";
  vertical = permille: percent (permille * screen.width / screen.height);
  # rofi resolves % against screen height for top/bottom sides and top-left/bottom-right radius corners
  box = permille: "${vertical permille} ${percent permille}";

  searchQuery = "query ($search: String) { Page(perPage: 20) { media(search: $search, type: ANIME, isAdult: false, sort: SEARCH_MATCH) { id title { userPreferred } coverImage { extraLarge } episodes status startDate { year } nextAiringEpisode { episode } mediaListEntry { progress } } } }";

  theme = pkgs.writeText "jerry-menu.rasi" ''
    * {
      font: "${font.name} ${toString font.size}";
      background-color: transparent;
      text-color: ${color.base05};
    }

    window {
      padding: ${box gap};
      border-radius: ${box windowRadius};
      background-color: ${color.base00}f5;
    }

    mainbox {
      spacing: ${vertical gap};
      children: [ inputbar, listview ];
    }

    inputbar {
      children: [ entry ];
    }

    entry {
      font: "${textFont}";
      cursor-color: ${color.base05};
      placeholder-color: ${color.base03};
    }

    listview {
      fixed-columns: true;
      fixed-height: true;
      flow: horizontal;
      spacing: ${box gap};
      scrollbar: false;
    }

    element {
      orientation: vertical;
      children: [ element-text, element-icon ];
      padding: ${box innerGap};
      spacing: ${vertical innerGap};
      border-radius: ${box elementRadius};
    }

    element selected {
      background-color: ${color.base0B}40;
    }

    element-icon {
      squared: false;
      border-radius: ${box iconRadius};
    }

    element-text {
      font: "${textFont}";
      horizontal-align: 0.5;
    }
  '';
in
pkgs.writeShellApplication {
  name = "jerry-menu";
  runtimeInputs = with pkgs; [
    curl
    jaq
    rofi
    uutils-coreutils-noprefix
  ];
  excludeShellChecks = [ "SC2016" ];
  text = ''
    gap=${toString gap}
    inner_gap=${toString innerGap}
    max_column=${toString maxColumn}
    max_entry_width=${toString maxEntryWidth}
    max_window_width=${toString maxWindowWidth}
    pick_column=${toString pickColumn}
    pick_line=${toString pickLine}
    cover_height_scale=${toString (screen.width * cover.height)}
    cover_width_scale=${toString (screen.height * cover.width)}

    cover_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/jerry/cover"
    mkdir -p "$cover_dir"

    rofi_option=(
    	-i -p "" -theme ${theme}
    	-kb-move-char-back Control+b -kb-move-char-forward Control+f
    	-kb-row-left "Left,Control+Page_Up" -kb-row-right "Right,Control+Page_Down"
    )

    percent() {
    	printf '%d.%d%%' $(($1 / 10)) $(($1 % 10))
    }

    smallest() {
    	printf '%d' $(($1 < $2 ? $1 : $2))
    }

    layout() {
    	local column=$1 line=$2 placeholder=$3 entry_width window_width cover_height
    	entry_width=$(smallest $(((max_window_width - (column + 1) * gap) / column)) "$max_entry_width")
    	window_width=$((column * entry_width + (column + 1) * gap))
    	cover_height=$(((entry_width - 2 * inner_gap) * cover_height_scale / cover_width_scale))
    	printf 'window { width: %s; } listview { columns: %d; lines: %d; } element-icon { size: %s; } entry { placeholder: "%s"; }' \
    		"$(percent "$window_width")" "$column" "$line" "$(percent "$cover_height")" "$placeholder"
    }

    escape() {
    	local text=''${1//&/\&amp;}
    	text=''${text//</\&lt;}
    	printf '%s' "''${text//>/\&gt;}"
    }

    fetch_cover() {
    	local id cover_url
    	while IFS=$'\t' read -r id cover_url _; do
    		[[ -s $cover_dir/$id ]] || curl -s -o "$cover_dir/$id" "$cover_url" &
    	done <<<"$1"
    	wait
    }

    card() {
    	local id title progress total status releasing=""
    	IFS=$'\t' read -r id _ title progress total status _ <<<"$1"
    	[[ $status == RELEASING ]] && releasing=' <span style="italic" foreground="${color.base0D}">releasing</span>'
    	printf '%s\0icon\x1f%s' \
    		"<span weight=\"bold\" foreground=\"${color.base05}\">$(escape "$title")</span>&#10;<span weight=\"bold\" foreground=\"${color.base0B}\">$progress</span><span foreground=\"${color.base03}\">/</span>$total$releasing" \
    		"$cover_dir/$id"
    }

    list() {
    	local row selected
    	mapfile -t row
    	((''${#row[@]})) || return 0
    	fetch_cover "$(printf '%s\n' "''${row[@]}")"

    	selected=$(for item in "''${row[@]}"; do
    		card "$item"
    		printf '\n'
    	done | rofi -dmenu "''${rofi_option[@]}" -markup-rows -show-icons -eh 2 -format i \
    		-theme-str "$(layout "$(smallest "''${#row[@]}" "$max_column")" 1 "")") || return 0

    	cut -f1 <<<"''${row[selected]}"
    }

    search_result() {
    	local header=(-H 'Content-Type: application/json') row
    	[[ -n ''${ANILIST_TOKEN:-} ]] && header+=(-H "Authorization: Bearer $ANILIST_TOKEN")

    	mapfile -t row < <(jaq -n -c --arg query '${searchQuery}' --arg search "$1" '{query: $query, variables: {search: $search}}' |
    		curl -s -X POST https://graphql.anilist.co "''${header[@]}" --data @- |
    		jaq -r '.data.Page.media[] | [.id, .coverImage.extraLarge, .title.userPreferred, (.mediaListEntry.progress // 0), (.episodes // "?"), .status, (.startDate.year // "?"), 0, (if .nextAiringEpisode then .nextAiringEpisode.episode - 1 else (.episodes // 1) end)] | @tsv')
    	fetch_cover "$(printf '%s\n' "''${row[@]}")"

    	printf '\0markup-rows\x1ftrue\n'
    	((''${#row[@]})) || printf 'no result\0nonselectable\x1ftrue\n'
    	for item in "''${row[@]}"; do
    		card "$item"
    		printf '\x1finfo\x1f%s\n' "$item"
    	done
    }

    search_step() {
    	case ''${ROFI_RETV:-0} in
    		0) printf '\0markup-rows\x1ftrue\n' ;;
    		1) printf '%s\n' "$ROFI_INFO" >"$JERRY_MENU_RESULT" ;;
    		2) search_result "$1" ;;
    	esac
    }

    search() {
    	JERRY_MENU_RESULT=$(mktemp)
    	export JERRY_MENU_RESULT
    	rofi -modi "search:$0 search-step" -show search "''${rofi_option[@]}" -show-icons -eh 2 \
    		-theme-str "$(layout "$max_column" 1 search)" || true
    	cat "$JERRY_MENU_RESULT"
    	rm -f "$JERRY_MENU_RESULT"
    }

    pick() {
    	local placeholder=$1 selected_row=$2 choice column line selected
    	mapfile -t choice
    	((''${#choice[@]})) || return 0
    	column=$(smallest "''${#choice[@]}" "$pick_column")
    	line=$(smallest $(((''${#choice[@]} + column - 1) / column)) "$pick_line")

    	selected=$(for item in "''${choice[@]}"; do
    		printf '<span weight="bold">%s</span>\n' "$(escape "$item")"
    	done | rofi -dmenu "''${rofi_option[@]}" -markup-rows -eh 1 -format i -selected-row "$selected_row" \
    		-theme-str "$(layout "$column" "$line" "$placeholder") element { children: [ element-text ]; }") || return 0

    	printf '%s\n' "''${choice[selected]}"
    }

    case ''${1:-} in
    	list) list ;;
    	search) search ;;
    	search-step) search_step "''${2:-}" ;;
    	pick) pick "$2" "$3" ;;
    esac
  '';
}
