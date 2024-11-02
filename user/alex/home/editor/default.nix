{pkgs, ...}: {
  dp.editor = "${pkgs.neovim}/bin/nvim";

  imports = [
    ./neovim
    ./vscode # I want to switch to a FOSS rust alternative!
    # ./helix
  ];
}
