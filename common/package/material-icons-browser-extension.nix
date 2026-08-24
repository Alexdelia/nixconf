{
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage {
  pname = "material-icons-browser-extension";
  version = "1.16.3";

  src = fetchFromGitHub {
    owner = "material-extensions";
    repo = "material-icons-browser-extension";
    rev = "28ce0159385169e95387026d19c7eaa8cdd505e7";
    hash = "sha256-2SBfAAhkXkR2fi11sAVg3+FGM8nLlaVKXTg8z96l8og=";
  };

  patches = [
    ../patch/material-icons-browser-extension-self-hosted-port.patch
    ../patch/material-icons-browser-extension-forgejo-diff-tree.patch
    ../patch/material-icons-browser-extension-local-instance.patch
  ];

  npmDepsHash = "sha256-c8i1OUWP/42N1DZHIq5p9PyQzH+FcnbvAjyvLswuEqo=";

  extensionKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0FaVeIhWkhIHqGUs5Yl5NVvcDomeSYnHTeF9qjtp9qKLCiu+Lv9hkjsU69tX5eZanJ5vy6cNaeNXIn6BBAta+HRf8iminZ33Cxs9xW3rqG5HU13d3UoQE/C6AvEGRbMlzxU3KTUpdkxkaTkAAqSlT07gzBC1dKTlPJRrRpqsJvYpcujIfWsGetwDJL6024TEbRRPg4kkd1GJ8if7mZE7frUyne5J3Sa5/Djxlb+ZuVDFYuQFj5j/8iyt1IcFmSSlIb6jVf0HTyI9hDRkvped4cZjDGr/S6jvOyHWoDLoD3ZCyOssaPYFzfp8sGLjtrKPbnEJLq+nQ5iTGedy8UAMZwIDAQAB";

  postPatch = ''
    substituteInPlace src/manifests/base.json \
      --replace-fail '"name": "Material Icons for GitHub",' \
      '"key": "'"$extensionKey"'", "name": "Material Icons for GitHub",'
  '';

  npmBuildScript = "build-src";

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    npx vitest run
    npx tsc -p ./
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    cp -r dist/chrome-edge $out
    runHook postInstall
  '';
}
