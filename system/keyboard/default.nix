{pkgs, ...}: let
  layout = ./qwerty-dev-fr.xkb;

  compiledLayout = pkgs.runCommand "compiled-keyboard-layout" {} ''
    ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${layout} $out
  '';
in {
  environment.systemPackages = [pkgs.xorg.xkbcomp];

  # Load custom keyboard layout on boot/resume
  services.xserver.displayManager.sessionCommands = "${pkgs.xorg.xkbcomp}/bin/xkbcomp ${layout} $DISPLAY";

  # Configure the console keymap from the xserver keyboard settings
  console.useXkbConfig = true;
}
