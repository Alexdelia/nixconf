{lib, ...}: {
  programs = {
    kitty = {
      enable = true;

      font = lib.mkForce {
        name = "SourceCodePro";
        size = 16;
      };

      settings = {
        enable_audio_bell = false;

        allow_remote_control = true;
      };
    };
  };

  # stylix.targets.kitty.enable = false;
}
