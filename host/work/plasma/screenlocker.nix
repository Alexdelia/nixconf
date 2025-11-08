{pkgs, ...}: {
  programs.plasma.kscreenlocker = {
    autoLock = false;
    lockOnResume = true;

    passwordRequired = true;
    passwordRequiredDelay = 10;

    appearance = {
      alwaysShowClock = true;
      showMediaControls = true;

      wallpaper = pkgs.fetchurl {
        url = "https://w.wallhaven.cc/full/76/wallhaven-76qoqv.png";
        sha256 = "sha256-OYwWr1u1gMJe1BwHeYVGiOWiwaxm8Rr86ofPgAnq1j0=";
      };
    };
  };
}
