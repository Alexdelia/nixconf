{
  pkgs,
  config,
  ...
}: let
  package =
    if !config.targets.genericLinux.enable
    then pkgs.brave
    else
      pkgs.chromium.overrideAttrs (old: {
        buildCommand = let
          oldStr = ''
            if [ -x "/run/wrappers/bin/${old.passthru.sandboxExecutableName}" ]
            then
              export CHROME_DEVEL_SANDBOX="/run/wrappers/bin/${old.passthru.sandboxExecutableName}"
            else
              export CHROME_DEVEL_SANDBOX="$sandbox/bin/${old.passthru.sandboxExecutableName}"
            fi
          '';
          newStr = ''export CHROME_DEVEL_SANDBOX=/opt/google/chrome/chrome-sandbox'';
        in
          builtins.replaceStrings [oldStr] [newStr] old.buildCommand;
      });
in {
  imports = [
    ./extension
  ];

  programs.chromium = {
    enable = true;

    inherit package;

    commandLineArgs = [
      "--ozone-platform-hint=auto"

      "--disable-features=GlobalShortcutsPortal"
    ];
  };
}
