{ scheme }:
with scheme;
let
  back_primary = "524554";
in
{
  colors = {
    regular0 = base10;
    regular1 = base08;
    regular2 = base0B;
    regular3 = base0A;
    regular4 = base0D;
    regular5 = base0E;
    regular6 = base0C;
    regular7 = base06; # not base05 on purpose;

    bright0 = base04;
    bright1 = base12;
    bright2 = base14;
    bright3 = base13;
    bright4 = base16;
    bright5 = base17;
    bright6 = base15;
    bright7 = base07;

    background = base00;
    foreground = base05;

    cursor = "${base00} ${back_primary}";

    selection-foreground = base05;
    selection-background = back_primary;
  };
}
