{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    kanata-with-cmd
  ];

  xdg.configFile."kanata/kanata.kbd".text = (import ./kbd.nix { inherit pkgs; });
  systemd.user.services.kanata = {
    Unit = {
      Description = "Kanata";
      Documentation = "https://github.com/jtroo/kanata";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kanata-with-cmd}/bin/kanata --cfg ${config.xdg.configFile."kanata/kanata.kbd".target}";
      Restart = "never";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
