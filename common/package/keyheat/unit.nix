{
  lib,
  keyheat,
  host,
  user,
  keymap,
}:
let
  tapName = "swhkd tap";

  arguments = {
    inherit host user;
    state-dir = "/var/lib/keyheat";
    pause-file = "/run/keyheat/paused";
    tap-name = tapName;
    ignored-chord = "ctrl+super+k";
    inherit (keymap)
      rules
      model
      layout
      variant
      options
      ;
    xkb-dir = "${keyheat.xkb}";
  };
in
{
  execStart = lib.concatStringsSep " " (
    [ (lib.getExe keyheat) ]
    ++ lib.mapAttrsToList (name: value: "--${name} ${lib.escapeShellArg value}") arguments
  );

  serviceConfig = {
    User = "keyheat";
    Group = "keyheat";
    SupplementaryGroups = [ "input" ];
    StateDirectory = "keyheat";
    StateDirectoryMode = "0750";
    RuntimeDirectory = "keyheat";
    RuntimeDirectoryMode = "0770";
    UMask = "0027";
    PrivateNetwork = true;
    IPAddressDeny = "any";
    RestrictAddressFamilies = [ "AF_UNIX" ];
    ProtectSystem = "strict";
    ProtectHome = true;
    NoNewPrivileges = true;
    PrivateTmp = true;
    SystemCallFilter = [ "@system-service" ];
    SystemCallArchitectures = "native";
    CapabilityBoundingSet = "";
    AmbientCapabilities = "";
    DevicePolicy = "closed";
    DeviceAllow = [ "char-input rw" ];
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    RemoveIPC = true;
    Restart = "on-failure";
    RestartSec = 10;
  };

  udevRule = ''SUBSYSTEM=="input", ATTRS{name}=="${tapName}", ENV{LIBINPUT_IGNORE_DEVICE}="1", TAG-="power-switch"'';
}
