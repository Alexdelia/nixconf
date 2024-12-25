{
  config,
  # pkgs,
  # lib,
  ...
}: {
  /*
  home.packages = with pkgs; [
    mpdris2
  ];
  */

  services.mpdris2.enable = config.hostOption.entertainment.music;

  /*
  systemd.user.services.mpdris2 = {
    Service = {
      Type = lib.mkForce "dbus";

      # ExecStart = lib.mkForce "${config.services.mpdris2.package}/bin/mpDris2 --debug";

      ExecStartPost = "${pkgs.dbus}/bin/dbus-send --session --dest=org.mpris.MediaPlayer2.mpd --type=method_call --print-reply /org/mpris/MediaPlayer2 org.freedesktop.DBus.Peer.Ping";
    };

    Unit.After = lib.mkForce [
      "mpd.service"
      "pulseaudio.service"
      "graphical-session.target"
    ];
  };
  */
}
