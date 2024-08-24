{pkgs, lib, ...}: {
  services.xserver = {
    enable = true;

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gedit # text editor
    ])
    ++ (with pkgs.gnome; [
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

	programs.dconf = {
		enable = true;

		profiles.user.databases = [{
        	lockAll = true; # prevents overriding

        	settings = {
				"org/gnome/desktop/wm/preferences" = {
					num-workspaces = lib.gvariant.mkUint16 10;
				};
				"org/gnome/shell/app-switcher" = {
					current-workspace-only = true;
				};
			};
		}];
	};
}
