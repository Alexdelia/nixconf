{config, ...}: {
  programs.chromium.extensions =
    [
      (import
        ./dark_reader.nix)
      (import
        ./material_icons_for_github.nix)
      (import
        ./tampermonkey.nix)
      (import
        ./improved_intra_42.nix)
    ]
    ++ (
      if config.hostOption.entertainment.gaming
      then [
        (import
          ./protondb.nix)
        (import
          ./augmented_steam.nix)
        (import
          ./steamdb.nix)
      ]
      else []
    );
}
