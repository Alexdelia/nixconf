{
  config,
  pkgs,
  ...
}:
let
  switchSink = import ./switch-sink.nix { inherit pkgs; };
  sinkPick = import ./sink-pick.nix { inherit config pkgs switchSink; };
in
{
  home.packages = [
    switchSink
    sinkPick
  ];

  customScript = {
    switchSink = "${switchSink}/bin/switch-sink";
    sinkPick = "${sinkPick}/bin/sink-pick";
  };
}
