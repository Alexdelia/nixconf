{ lib, ... }:
let
  role = import ../../../user/alex/home/de/sway/role.nix;

  desktopSwitch =
    role.list
    |> builtins.length
    |> lib.range 1
    |> lib.concatMap (
      i:
      let
        n = toString i;
        digit = if i == builtins.length role.list then "0" else n;
      in
      [
        {
          name = "Switch to Desktop ${n}";
          value = [ "Meta+${digit}" ] ++ lib.optional (i <= 4) "Ctrl+F${n}";
        }
        {
          name = "Window to Desktop ${n}";
          value = "none";
        }
      ]
    )
    |> lib.listToAttrs;
in
{
  programs.plasma = {
    shortcuts = {
      kwin = desktopSwitch;

      plasmashell."activate application launcher" = [ "Meta+F1" ];
    };

    spectacle.shortcuts = {
      captureRectangularRegion = "Meta+S";
      recordRegion = "none";
    };
  };
}
