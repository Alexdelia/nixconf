{ pkgs, ... }: {
  dp.editor = "${pkgs.neovim}/bin/nvim";
  dm.editor = "nvim.desktop";

  imports = [
    ./neovim
    # ./vscode
    # ./helix
  ];
}
