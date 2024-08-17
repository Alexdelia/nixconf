{lib, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "copilot.vim"
    ];

  imports = [
    ./pkg
    ./font
    ./shell
    ./script
    ./tty
    ./editor
    ./browser
  ];
}
