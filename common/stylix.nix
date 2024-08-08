{pkgs, ...}: {
  stylix = {
    enable = true;

    image = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/o3/wallhaven-o31o2p.png";
      sha256 = "sha256-KMTq1cvtV2jd+hOCBxkMWN1nZDllH9aWotqO3i0tcaw=";
    };
  };
}
