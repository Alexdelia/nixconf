{
  pkgs,
  dubbed ? false,
  ...
}:
let
  dub = pkgs.lib.optionalString dubbed " --dub";
in
pkgs.writeShellApplication {
  name = if dubbed then "anib" else "ani";
  runtimeInputs = with pkgs; [ ani-cli ];
  text = ''
    if [[ $# -eq 0 ]]; then
    	exec ani-cli${dub} --continue
    fi

    exec ani-cli${dub} "$@"
  '';
}
