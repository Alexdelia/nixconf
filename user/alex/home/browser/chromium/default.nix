{pkgs, ...}: {
  imports = [
    ./extension
  ];

  programs.chromium = {
    enable = true;

    package = pkgs.brave;

    commandLineArgs = [
      "--ozone-platform-hint=auto"

      "--disable-features=GlobalShortcutsPortal"
    ];
  };
}
