{lib, ...}: {
  programs.bash.initExtra =
    lib.mkAfter
    /*
    bash
    */
    ''
      _nc_nix_shell_complete() {
      	local cur synthetic i cidx line have_type
      	cur="''${COMP_WORDS[COMP_CWORD]}"
      	synthetic=(nix shell)
      	for ((i = 1; i < COMP_CWORD; i++)); do
      		synthetic+=("nixpkgs#''${COMP_WORDS[i]}")
      	done
      	synthetic+=("nixpkgs#$cur")
      	cidx=$((''${#synthetic[@]} - 1))

      	COMPREPLY=()
      	while IFS= read -r line; do
      		line="''${line%%$'\t'*}"
      		if [[ -z $have_type ]]; then
      			have_type=1
      			[[ $line == attrs ]] && compopt -o nospace
      			continue
      		fi
      		COMPREPLY+=("''${line#nixpkgs#}")
      	done < <(NIX_GET_COMPLETIONS=$cidx "''${synthetic[@]}" 2>/dev/null)
      }

      complete -F _nc_nix_shell_complete nr ns nsu nus nusu
    '';
}
