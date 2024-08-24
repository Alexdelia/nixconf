{pkgs, ...}: {
  services.xserver = {
    enable = true;

    displayManager.gdm.enable = true;

    desktopManager.gnome = {
		enable = true;

		extraGSettingsOverrides = ''
[org.gnome.desktop.wm.preferences]
num-workspaces=10
		'';
	};
  };

  environment.gnome.excludePackages = (with pkgs; [
  gnome-photos
  gnome-tour
  gedit # text editor
]) ++ (with pkgs.gnome; [
  cheese # webcam tool
  gnome-music
  gnome-terminal
  epiphany # web browser
  geary # email reader
  evince # document viewer
  gnome-characters
  totem # video player
  tali # poker game
  iagno # go game
  hitori # sudoku game
  atomix # puzzle game
]);
}
