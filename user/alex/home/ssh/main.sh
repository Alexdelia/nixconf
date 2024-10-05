#! /usr/bin/env -S nix shell nixpkgs#bash nixpkgs#ripgrep nixpkgs#skim --command bash

ssh $(rg '^Host\s(.*)' ~/.ssh/config -r '$1' | sk)
