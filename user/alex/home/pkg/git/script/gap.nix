{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "gap";
  runtimeInputs = with pkgs; [
    git
    wakatime-cli
  ];
  text = ''
    if [[ $# -eq 0 ]]; then
    	git add --intent-to-add .
    else
    	git add --intent-to-add "$@"
    fi

    root=$(git rev-parse --show-toplevel)
    heartbeat_interval_seconds=60

    log_review_while_open() {
    	local pause=""
    	trap 'if [[ -n $pause ]]; then kill "$pause" 2>/dev/null || true; fi; exit 0' TERM
    	while :; do
    		wakatime-cli --entity "$root/$1" --category "code reviewing" --plugin "gap/1.0" --sync-ai-disabled >/dev/null 2>&1 || true
    		sleep "$heartbeat_interval_seconds" &
    		pause=$!
    		wait "$pause"
    	done
    }

    ticker=""
    stop_ticker() {
    	if [[ -n $ticker ]]; then
    		kill "$ticker" 2>/dev/null || true
    		ticker=""
    	fi
    }
    trap stop_ticker EXIT

    mapfile -d "" -t files < <(git diff -z --name-only -- "$@")
    for file in "''${files[@]}"; do
    	log_review_while_open "$file" &
    	ticker=$!
    	git add -p -- ":(top,literal)$file"
    	stop_ticker
    done

    git status --short

    printf "\n\033[3mun-add:\033[0m\t\033[1;38;2;232;77;49mgit\033[39m restore \033[2m--staged\033[0m \033[1;35m<path>\033[0m\n\033[3m    or:\033[0m\t\033[1;38;2;232;77;49mg\033[39mr\033[2ms \033[35m[path]\033[0m\n"
  '';
}
