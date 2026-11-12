{ final, ... }:
let
  xkb = final.runCommand "keyheat-xkb" { } ''
    mkdir -p $out/rules $out/symbols
    cp ${../../../user/alex/home/keyboard/xkb/rules/evdev} $out/rules/evdev
    cp ${../../../user/alex/home/keyboard/xkb/symbols/custom} $out/symbols/custom
    cp ${../../../system/keyboard/qwerty-dev-ca.xkb} $out/symbols/qwerty-dev-ca
  '';

  toggle = final.writeShellApplication {
    name = "keyheat-toggle";
    runtimeInputs = [
      final.coreutils
      final.libnotify
    ];
    text = builtins.readFile ./toggle.sh;
  };
in
final.python3Packages.buildPythonApplication {
  pname = "keyheat";
  version = "0.1.0";
  pyproject = true;

  src = final.lib.fileset.toSource {
    root = ./.;
    fileset = final.lib.fileset.unions [
      ./pyproject.toml
      ./keyheat
      ./tests
    ];
  };

  build-system = [ final.python3Packages.setuptools ];

  dependencies = with final.python3Packages; [
    evdev
    xkbcommon
    jeepney
  ];

  nativeCheckInputs = [ final.python3Packages.pytestCheckHook ];

  preCheck = ''
    export KEYHEAT_TEST_XKB_DIR=${xkb}
  '';

  passthru = { inherit xkb toggle; };

  meta.mainProgram = "keyheat";
}
