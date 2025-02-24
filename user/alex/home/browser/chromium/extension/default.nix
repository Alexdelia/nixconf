{config, ...}: {
  programs.chromium.extensions =
    [
      (import ./dark_reader.nix)

      (import ./material_icons_for_github.nix)
      (import ./improved_intra_42.nix)

      (import ./language_tool.nix)
      # (import ./tampermonkey.nix)
    ]
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
