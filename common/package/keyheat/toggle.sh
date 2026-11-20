pause_file=/run/keyheat/paused

if [ -e "$pause_file" ]; then
	rm -f "$pause_file"
	notify-send keyheat resumed
else
	touch "$pause_file"
	notify-send keyheat paused
fi
