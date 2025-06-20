{
  config,
  pkgs,
  ...
}: {
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

          complete -F _complete_alias "''${!BASH_ALIASES[@]}"

          PROMPT_COMMAND="''${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
        '';

      bashrcExtra =
        /*
        bash
        */
        ''
          source ${pkgs.complete-alias}/bin/complete_alias
        '';

      shellAliases = import ../alias {inherit config pkgs;};

      # https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html
      shellOptions = [
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
        "checkjobs"
        "autocd"
        "complete_fullquote"
        "dotglob"
        "extquote"
        "failglob"
        "nocaseglob"
        "nocasematch"
      ];
      # TODO: test `progcomp_alias` instead of `complete_alias`

      historyFileSize =
        if (config.hostOption.type == "full")
        then 10000000 # 10M
        else if (config.hostOption.type == "minimal")
        then 1000 # 1K
        else 100000; # 100K
      historySize =
        if (config.hostOption.type == "full")
        then 100000 # 100K
        else if (config.hostOption.type == "minimal")
        then 100 # 100
        else 10000; # 10K

      historyControl = [
        "erasedups"
        "ignoredups"
      ];

      historyIgnore = [
        "exit"
        # "rm"
        # "l"
        # "ls"
        # "ll"
      ];

      historyFile = "${config.xdg.cacheHome}/bash/history";
    };
  };

  home.file."${config.xdg.cacheHome}/bash/dummy".text = "";
}
