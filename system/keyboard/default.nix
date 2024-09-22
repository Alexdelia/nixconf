{pkgs, ...}: let
  layout = "qwerty-dev-fr";
  # compiledLayout = pkgs.runCommand "compiled-keyboard-layout" {} ''
  # ${pkgs.xorg.xkbcomp}/bin/xkbcomp ${layout} $out
  # '';
in {
  # environment.systemPackages = [pkgs.xorg.xkbcomp];

  # Load custom keyboard layout on boot/resume
  # services.xserver.displayManager.sessionCommands = "${pkgs.xorg.xkbcomp}/bin/xkbcomp ${compiledLayout} $DISPLAY";

  # Configure the console keymap from the xserver keyboard settings
  console = {
    useXkbConfig = true;
    earlySetup = true;
  };

  services.xserver = {
    layout = layout;
    extraLayouts.${layout} = {
      description = ${layout};
      languages = ["en" "fr" "ca"];
      symbolsFile = ./${layout}.xkb;
    };
  };
}
