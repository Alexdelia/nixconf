{
  pkgs,
  color,
  font,
}:
let
  theme = pkgs.writeText "jerry-menu.rasi" ''
    * {
      font: "${font.name} ${toString font.size}";
      background-color: transparent;
      text-color: ${color.base05};
    }

    window {
      width: 100%;
      padding: 1.5%;
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
      columns: 8;
      lines: 1;
      fixed-columns: true;
      fixed-height: true;
      flow: horizontal;
      spacing: 1%;
      scrollbar: false;
    }

    element {
      orientation: vertical;
      padding: 0.5%;
      spacing: 0.5%;
      border-radius: 8px;
    }

    element selected {
      background-color: ${color.base0B}40;
    }

    element-icon {
      size: 26%;
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

    selected=$(for index in "''${!row[@]}"; do
    	printf '%s\0icon\x1f%s\n' "''${row[index]}" "$cover_dir/''${media_id[index]}"
    done | rofi -dmenu -i -markup-rows -show-icons -eh 2 -format i -p "" -theme ${theme} \
    	-kb-move-char-back Control+b -kb-move-char-forward Control+f \
    	-kb-row-left Left,Control+Page_Up -kb-row-right Right,Control+Page_Down) || exit 0

    printf '%s\n' "''${media_id[selected]}"
  '';
}
