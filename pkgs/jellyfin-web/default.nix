{
  buildNpmPackage,
  darwin,
  dart-sass,
  fetchFromGitHub,
  giflib,
  lib,
  overrideSDK,
  pango,
  pkg-config,
  stdenv,
  xcbuild,
}: let
  inherit (lib) optionals removePrefix;

  jellyfin-web-src = import ./src.nix;
  jellyfin-src = import ../jellyfin/src.nix;

  # node-canvas builds code that requires aligned_alloc,
  # which on Darwin requires at least the 10.15 SDK
  stdenv' =
    if stdenv.isDarwin
    then
      overrideSDK stdenv {
        darwinMinVersion = "10.15";
        darwinSdkVersion = "11.0";
      }
    else stdenv;
  buildNpmPackage' = buildNpmPackage.override {stdenv = stdenv';};
in
  buildNpmPackage' {
    pname = "jellyfin-web";
    version = removePrefix "v" jellyfin-web-src.rev;

    src = assert jellyfin-web-src.rev == jellyfin-src.rev;
      fetchFromGitHub jellyfin-web-src;

    npmDepsHash = import ./npmDepsHash.nix;

    npmBuildScript = ["build:production"];

    nativeBuildInputs = [pkg-config] ++ optionals stdenv.isDarwin [xcbuild];

    buildInputs =
      [pango]
      ++ optionals stdenv.isDarwin [
        giflib
        darwin.apple_sdk.frameworks.CoreText
      ];

    patches = [
      ./commit.patch
      ./lock.patch
    ];

    env = {
      COMMIT_SHA = jellyfin-web-src.rev;
      SASS_EMBEDDED_BIN_PATH = "${dart-sass}/bin/sass";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      cp -a dist $out/share/jellyfin-web

      runHook postInstall
    '';

    meta = with lib; {
      description = "Web Client for Jellyfin";
      homepage = "https://jellyfin.org/";
      license = licenses.gpl2Plus;
    };
  }
