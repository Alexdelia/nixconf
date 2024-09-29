{
  environment.sessionVariables = rec {
    NIXOS_OZONE_WL = "1";

    PATH = [XDG_BIN_HOME];

    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_BIN_HOME = "$HOME/.local/bin";

    EDITOR = "vim";

    # XAUTHORITY = "$XDG_CONFIG_HOME/Xauthority";

    WAKATIME_HOME = "${XDG_CONFIG_HOME}/wakatime";
  };
}
