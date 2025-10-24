{config, ...}: {
  programs.chromium.extensions =
    [
      (import ./dark_reader.nix)

      (import ./material_icons_for_github.nix)
      (import ./improved_intra_42.nix)
    ]
    ++ (
      if config.hostOption.type == "full"
      then [
        (import ./language_tool.nix)
        (import ./markdown_here.nix)

        # (import ./tampermonkey.nix)
      ]
      else []
    )
    ++ (
      if config.hostOption.entertainment.music
      then [
        (import ./web_scrobbler.nix)
      ]
      else []
    )
    ++ (
      if config.hostOption.entertainment.gaming
      then [
        (import ./protondb.nix)
        (import ./augmented_steam.nix)
        (import ./steamdb.nix)
      ]
      else []
    );
}
