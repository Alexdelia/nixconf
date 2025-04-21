{pkgs}: {
  j = "z";
  cp = "xcp -r";
  cat = "bat -p";
  ca = "${pkgs.uutils-coreutils-noprefix}/bin/cat";
  man = "batman";
  jq = "jaq";
}
