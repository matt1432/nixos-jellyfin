{
  lib,
  stdenv,
  overrideSDK,
  buildNpmPackage,
  nix-update-script,
  pkg-config,
  xcbuild,
  pango,
  giflib,
  darwin,
  jellyfin-web-src,
}:
let
  # node-canvas builds code that requires aligned_alloc,
  # which on Darwin requires at least the 10.15 SDK
  stdenv' =
    if stdenv.isDarwin then
      overrideSDK stdenv {
        darwinMinVersion = "10.15";
        darwinSdkVersion = "11.0";
      }
    else
      stdenv;
  buildNpmPackage' = buildNpmPackage.override { stdenv = stdenv'; };
in
buildNpmPackage' {
  pname = "jellyfin-web";
  version = "10.9.1";

  src = jellyfin-web-src;

  npmDepsHash = "sha256-LmbygyCYSp0gtjU2pNCV17WEyEoaIzPs7H9UoMFV+PU=";

  npmBuildScript = [ "build:production" ];

  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.isDarwin [ xcbuild ];

  buildInputs =
    [ pango ]
    ++ lib.optionals stdenv.isDarwin [
      giflib
      darwin.apple_sdk.frameworks.CoreText
    ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -a dist $out/share/jellyfin-web

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Web Client for Jellyfin";
    homepage = "https://jellyfin.org/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      nyanloutre
      minijackson
      purcell
      jojosch
    ];
  };
}