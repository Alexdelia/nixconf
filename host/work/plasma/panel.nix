{
  programs.plasma.panels = [
    {
      location = "bottom";
      height = 52;
      hiding = "autohide";
      lengthMode = "fill";
      opacity = "translucent";
      alignment = "center";

      widgets = [
        "org.kde.plasma.kickoff"
        "org.kde.plasma.pager"
        "org.kde.plasma.icontasks"
        "org.kde.plasma.marginsseparator"
        "org.kde.plasma.systemtray"
        "org.kde.plasma.digitalclock"
      ];
    }
  ];
}
