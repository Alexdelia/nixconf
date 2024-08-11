#! /usr/bin/env bash

git config --global --get-regexp "user."$1".*" \
	| sort -r \
	| cut -d" " -f2 \
	| bat --color=always -pp -l=qml