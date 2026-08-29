{ pkgs }:
let
  preview = pkgs.writeShellApplication {
    name = "git-identity-preview";
    runtimeInputs = with pkgs; [
      git
      bat
      uutils-coreutils-noprefix
    ];
    text = ''
      git config --global --get-regexp "user.$1.*" |
      	sort -r |
      	cut -d" " -f2 |
      	bat --color=always -pp -l=qml
    '';
  };

  identity = pkgs.writeShellApplication {
    name = "git-identity";
    runtimeInputs = with pkgs; [
      git
      ripgrep
      skim
      bat
    ];
    excludeShellChecks = [ "SC2016" ];
    text = ''
      id="$(
      	git config --global --name-only --get-regexp 'user.*..name' |
      		rg 'user\.(.*)\.name' -or '$1' |
      		sk --preview='${pkgs.lib.getExe preview} {}' --preview-window=down:3
      )"

      if ! git config --global --get-regexp "user.$id.name" >/dev/null; then
      	exit 78 # sysexits.h `EX_CONFIG` https://github.com/openbsd/src/blob/master/include/sysexits.h#L115
      fi

      git config user.name "$(git config "user.$id.name")"
      git config user.email "$(git config "user.$id.email")"

      printf 'name:\t%s\nemail:\t%s\n' \
      	"$(git config user.name)" \
      	"$(git config user.email)" |
      	bat --color=always -pp -l=qml
    '';
  };
in
[
  identity
  preview
]
