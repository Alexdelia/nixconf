{pkgs}: {
  j = "z";
  cp = "xcp -r";

  cat = "bat -p";
  ca = "${pkgs.uutils-coreutils-noprefix}/bin/cat";
  rat = "bat -pA";
  bar = "bat -pA";
  man = "batman";
  bam = "bat -l=man";
  baj = "bat -l=json";

  jq = "jaq";
}
