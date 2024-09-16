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
    ./tty
    ./editor
    ./browser
    ./de
  ];
}
