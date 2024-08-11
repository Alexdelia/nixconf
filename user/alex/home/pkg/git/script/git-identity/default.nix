{pkgs}: [
  (pkgs.writeScriptBin "git-identity" (builtins.readFile ./main.sh))
  (pkgs.writeScriptBin "git-identity-preview" (builtins.readFile ./preview.sh))
]
