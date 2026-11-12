import asyncio
import logging
import sys

from keyheat.counts import stored_keymap
from keyheat.daemon import Daemon, parse_args
from keyheat.store import StateFileError, load


def main() -> None:
	logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
	log = logging.getLogger("keyheat")
	config = parse_args(sys.argv[1:])
	try:
		counts = load(config.state_file)
	except StateFileError as error:
		raise SystemExit(str(error)) from None
	if counts.loaded_keymap not in (None, stored_keymap(config.keymap)):
		log.warning("keymap changed")
	asyncio.run(Daemon(config, counts).run())


if __name__ == "__main__":
	main()
