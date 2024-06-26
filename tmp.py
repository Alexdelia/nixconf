#! /usr/bin/env -S nix shell nixpkgs#python312 --command python3

import locale

# read all locale line by line from 
locale_file = open("locale.r", "r")

error = {}
seen = {}

for line in locale_file:
    try:
        locale.setlocale(locale.LC_ALL, line)
    except locale.Error as e:
        error[line] = e
        continue

    # store formatted number
    # format=f"{1234.56:n}"
    try:
        format=locale.currency(1234.56)
    except ValueError as e:
        error[line] = e
        continue

    if format not in seen:
        seen[format] = []

    seen[format].append(line)

# print(error)

for k, v in seen.items():
    print(f"{k}: {v}")