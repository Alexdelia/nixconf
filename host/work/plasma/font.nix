{
  programs = {
    plasma = {
      fonts = let
        family = "RobotoMono Nerd Font";
        baseSize = 14;

        baseFont = {
          inherit family;
          pointSize = baseSize;
        };
      in {
        fixedWidth = baseFont;
        general = baseFont;

        menu = baseFont;
        small = {
          inherit family;
          pointSize = baseSize - 2;
        };
        toolbar = baseFont;
        windowTitle = baseFont;
      };
    };
  };
}
