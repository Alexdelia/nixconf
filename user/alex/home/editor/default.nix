{pkgs, ...}: {
  dp.editor = "${pkgs.neovim}/bin/nvim";

  imports = [
    ./neovim
    # ./vscode
    # ./helix
  ];
}
