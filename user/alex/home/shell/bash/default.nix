{pkgs, ...}: {
  /*
  home.packages = with pkgs; [
    # syntax highlight
    # history
    # completion
    # ...
  ];
  */

  programs = {
    bash = {
      enable = true;

      shellAliases = import ../alias;
    };
  };
}
