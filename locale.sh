#! /usr/bin/env -S nix shell nixpkgs#bash --command bash

number=1234.56

declare -A seen

for locale in $(locale -a); do
	LC_ALL=$locale

	# formatted=$(printf "%'.f\n" $number) || printf "\n%s" $locale # 2>/dev/null) || continue
	formatted=$(awk "{printf \"%'.2f\n\", \$1}" <<< $number) || printf "\n%s" $locale # 2>/dev/null) || continue

	if [[ -z ${seen[$formatted]} ]]; then
		seen[$formatted]=$locale

		printf "\n\033[1;32m%s\033[0m\n" $locale
		printf "%s\n" $formatted
	fi

	# print numeric with $locale	
	# echo '1234.56' | awk '{printf "%.2f\n", $1}'
	# printf "%'.f\n" 1234.56 || echo "Error: $locale" && continue
done