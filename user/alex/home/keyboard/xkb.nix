{
  xdg.configFile = {
    "xkb/rules/evdev".text = ''
      ! include %S/evdev

      ! option = symbols
        custom:no_backspace = +custom(no_backspace)
    '';

    "xkb/symbols/custom".text = ''
      partial alphanumeric_keys
      xkb_symbols "no_backspace" {
          key <BKSP> { type = "ONE_LEVEL", [ VoidSymbol ] };
      };
    '';
  };
}
