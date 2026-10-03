{
  pkgs,
  color,
  font,
  maxColumn ? 3,
  maxCoverHeight ? 600,
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

  windowPadding = 15;
  spacing = 10;
  elementPadding = 5;
  maxEntryWidth =
    maxCoverHeight * screen.height * cover.width / (screen.width * cover.height) + 2 * elementPadding;

  percent = permille: "${toString (permille / 10)}.${toString (pkgs.lib.mod permille 10)}%";

  theme = pkgs.writeText "jerry-menu.rasi" ''
    * {
      font: "${font.name} ${toString font.size}";
      background-color: transparent;
      text-color: ${color.base05};
    }

    window {
      padding: ${percent windowPadding};
      background-color: ${color.base00}f5;
    }

    mainbox {
      spacing: 2%;
      children: [ inputbar, listview ];
    }

    inputbar {
      children: [ entry ];
    }

    entry {
      placeholder: "";
      cursor-color: ${color.base0B};
    }

    listview {
      lines: 1;
      fixed-columns: true;
      fixed-height: true;
      flow: horizontal;
      spacing: ${percent spacing};
      scrollbar: false;
    }

    element {
      orientation: vertical;
      children: [ element-text, element-icon ];
      padding: ${percent elementPadding};
      spacing: ${percent elementPadding};
      border-radius: 8px;
    }

    element selected {
      background-color: ${color.base0B}40;
    }

    element-icon {
      squared: false;
    }

    element-text {
      horizontal-align: 0.5;
    }
  '';
in
pkgs.writeShellApplication {
  name = "jerry-menu";
  runtimeInputs = with pkgs; [
    curl
    rofi
    uutils-coreutils-noprefix
  ];
  text = ''
    percent() {
    	printf '%d.%d%%' $(($1 / 10)) $(($1 % 10))
    }

    cover_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/jerry/cover"
    mkdir -p "$cover_dir"

    media_id=()
    row=()
    while IFS=$'\t' read -r id cover_url title progress total status _ _; do
    	[[ -s $cover_dir/$id ]] || curl -s -o "$cover_dir/$id" "$cover_url" &

    	title=''${title//&/\&amp;}
    	title=''${title//</\&lt;}
    	title=''${title//>/\&gt;}
    	releasing=""
    	[[ $status == RELEASING ]] && releasing=' <span style="italic" foreground="${color.base0D}">releasing</span>'

    	media_id+=("$id")
    	row+=("<span size=\"larger\" weight=\"bold\" foreground=\"${color.base05}\">$title</span>&#10;<span size=\"small\"><span weight=\"bold\" foreground=\"${color.base0B}\">$progress</span><span foreground=\"${color.base03}\">/</span>$total$releasing</span>")
    done
    wait

    column=$((''${#row[@]} < ${toString maxColumn} ? ''${#row[@]} : ${toString maxColumn}))
    entry_width=$(((1000 - ${toString (2 * windowPadding)} - (column - 1) * ${toString spacing}) / column))
    entry_width=$((entry_width < ${toString maxEntryWidth} ? entry_width : ${toString maxEntryWidth}))
    window_width=$((column * entry_width + (column - 1) * ${toString spacing} + ${toString (2 * windowPadding)}))
    cover_height=$(((entry_width - ${toString (2 * elementPadding)}) * ${
      toString (screen.width * cover.height)
    } / ${toString (screen.height * cover.width)}))
    layout="window { width: $(percent "$window_width"); } listview { columns: $column; } element-icon { size: $(percent "$cover_height"); }"

    selected=$(for index in "''${!row[@]}"; do
    	printf '%s\0icon\x1f%s\n' "''${row[index]}" "$cover_dir/''${media_id[index]}"
    done | rofi -dmenu -i -markup-rows -show-icons -eh 2 -format i -p "" -theme ${theme} -theme-str "$layout" \
    	-kb-move-char-back Control+b -kb-move-char-forward Control+f \
    	-kb-row-left Left,Control+Page_Up -kb-row-right Right,Control+Page_Down) || exit 0

    printf '%s\n' "''${media_id[selected]}"
  '';
}
