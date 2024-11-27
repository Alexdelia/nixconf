{lib, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "copilot.vim"
    ];

  imports = [
    ../../../common/option

    ./fs
    ./pkg
    ./font
    ./keyboard
    ./shell
    ./script
    ./ssh
    ./tty
    ./music
    ./calculator
    ./editor
    ./browser
    ./de
    ./sops
  ];
}
