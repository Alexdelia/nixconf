{
  # pkgs,
  ...
}: {
  /*
  home.packages = with pkgs; [
    # syntax highlight
    # history
    # completion
    # ...
  ];
  */

  imports = [
    ./readline.nix
  ];

  programs = {
    bash = {
      enable = true;

      initExtra = ''
        export EDITOR="vim"
      '';

      shellAliases = import ../alias;
    };
  };
}
