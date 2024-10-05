{lib, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "copilot.vim"
    ];

  imports = [
    ./pkg
    ./font
    ./keyboard
    ./shell
    ./script
	./ssh
    ./tty
    ./editor
    ./browser
    ./de
  ];
}
