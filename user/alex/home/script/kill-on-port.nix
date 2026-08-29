{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "kill-on-port";
  runtimeInputs = with pkgs; [
    findutils
    lsof
  ];
  text = ''
    if [[ $# -lt 1 ]]; then
    	printf 'usage: \033[1m%s \033[35m<port>\033[0m\n' "$0"
    	exit 64 # sysexits.h `EX_USAGE` https://github.com/openbsd/src/blob/master/include/sysexits.h#L101
    fi

    lsof -i:"$1" -sTCP:LISTEN -t | xargs -r kill || true
  '';
}
