{
  environment.sessionVariables = rec {
    PATH = [ "${XDG_BIN_HOME}" ];

    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    XDG_BIN_HOME    = "$HOME/.local/bin";

    EDITOR = "hx";

    # XAUTHORITY = "$XDG_CONFIG_HOME/Xauthority";
  };
}
