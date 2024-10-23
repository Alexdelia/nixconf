{
  # pkgs,
  ...
}: {
  /*
  home.packages = with pkgs; [
    # syntax highlight
    # history
    # completion
    # ...
  ];
  */

  imports = [
    ./readline.nix
  ];

  programs = {
    bash = {
      enable = true;

      initExtra =
        /*
        bash
        */
        ''
          export EDITOR="vim"

          function wa() {
            if [[ $# -ne 1 ]]; then
              printf "usage: \033[1m$0 \033[35m<thing>\033[0m\n"
              return 64 # sysexits.h `EX_USAGE` https://github.com/openbsd/src/blob/master/include/sysexits.h#L101
            fi

            local TYPE="$(type -t "$1")"

            case "$TYPE" in
              file)
                bat $(type "$1" | sed 's/.*is\s//')
                ;;
              alias)
                type "$1" | sed 's/.*`//' | sed 's/.$//' | bat -p -l=bash
                ;;
              function)
                type "$1" | tail +2 | bat -p -l=bash
                ;;
              # builtin)
              #   printf "\033[1m$1\033[0m is a builtin\n"
              #   ;;
              # keyword)
              #   ;;
              *)
                type "$1" | bat -p -l=bash
                ;;
            esac
          }
        '';

      shellAliases = import ../alias;
    };
  };
}
