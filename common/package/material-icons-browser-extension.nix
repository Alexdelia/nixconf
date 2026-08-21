{
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage {
  pname = "material-icons-browser-extension";
  version = "1.16.3-unstable-2026-08-21";

  src = fetchFromGitHub {
    owner = "material-extensions";
    repo = "material-icons-browser-extension";
    rev = "28ce0159385169e95387026d19c7eaa8cdd505e7";
    hash = "sha256-2SBfAAhkXkR2fi11sAVg3+FGM8nLlaVKXTg8z96l8og=";
  };

  patches = [
    ../patch/material-icons-browser-extension-self-hosted-port.patch
    ../patch/material-icons-browser-extension-local-instance.patch
  ];

  npmDepsHash = "sha256-c8i1OUWP/42N1DZHIq5p9PyQzH+FcnbvAjyvLswuEqo=";

  extensionKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAx3TQSr97ekiRSwjmJ83wwFj0tfO7/8gMkWdyfI12AA5zYlUKFIOsoxvM6JR3oG9cNOjtg4npK3N+n0DLjdOz1EzYlp1ph5ky2FzyuwvxukCji0VBI1tIXNlwwneR+H/rUNP+lC+zPcRzYwkLg1tntThMjnbsXAX8QjZ50DUsM0OW7hQT6mnkqVQHqHHGlkh7HD/FtIHqCO2s/JQT8trW5U/6Z6yBVuIa9mbIeLla7XUHEEvqriQ9tyJ0Mr3Bid/wxlT3maGxYND8QBiEC/4aWdQwn+sIpmKiedJxgnMv2L5gAmQhu64l7dELySkWoAAyZtNoaS3dk5PJx+Lfbe5GZwIDAQAB";

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
