{pkgs, ...}: (
  pkgs.writers.writeBashBin
  "gcv" {}
  /*
  bash
  */
  ''
    if [[ $# -ne 2 ]]; then
    	printf "usage: \033[1m$0 \033[35m<semver> <commit-message>\033[0m\n"
    	exit 64 # sysexits.h `EX_USAGE` https://github.com/openbsd/src/blob/master/include/sysexits.h#L101
    fi

    git commit -m 'ver: `'"$1"'` - '"$2" --no-verify --quiet
    git tag -a "v$1" -m 'version `'"$1"'` - '"$2"
    git push --no-verify --quiet
    git push origin tag "v$1" --no-verify --quiet

    git show --summary
  ''
)
