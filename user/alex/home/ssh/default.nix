{
  pkgs,
  config,
  ...
}:
let
  name = "ssh-fuzzy";

  fuzzy = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      openssh
      ripgrep
      skim
    ];
    # rg replacement `$1` must reach rg literally
    excludeShellChecks = [ "SC2016" ];
    text = ''
      host="$(rg '^Host\s(.*)' "$HOME/.ssh/config" -r '$1' | sk)"
      ssh "$host"
    '';
  };
in
{
  home.packages = [
    fuzzy
    (pkgs.writeShellApplication {
      name = "${name}-open";
      runtimeInputs = [ fuzzy ];
      text = config.terminal.exec { command = name; };
    })
  ];
}
