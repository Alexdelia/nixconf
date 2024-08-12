{pkgs, ...}: {
  home.packages = with pkgs; [
    zsh-syntax-highlighting
  ];

  programs = {
    zsh = {
      enable = true;

      dotDir = ".config/zsh";

      initExtra = ''
        # be able to use ctrl + backspace / crtl + delete to delete entire word
        bindkey '5~' kill-word
        bindkey '^H' backward-kill-word
        # be able to use ctrl + left / ctrl + right to move word by word
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;5D' backward-word

        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      '';

      shellAliases = import ../alias;
    };
  };
}
