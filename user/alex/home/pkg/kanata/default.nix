{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    kanata
  ];

  xdg.configFile."kanata/kanata.kbd".source = ./kanata.kbd;
  systemd.user.services.kanata = {
    Unit = {
      Description = "Kanata";
      Documentation = "https://github.com/jtroo/kanata";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${config.xdg.configFile."kanata/kanata.kbd".target}";
      Restart = "never";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
