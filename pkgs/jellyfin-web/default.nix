{
  lib,
  buildNpmPackage,
  darwin,
  fetchFromGitHub,
  giflib,
  overrideSDK,
  pango,
  pkg-config,
  stdenv,
  xcbuild,
  forceEnableBackdrops ? false,
}: let
  inherit (lib) optionals optionalString removePrefix;

  jellyfin-web-src = import ./src.nix;
  jellyfin-src = import ../jellyfin/src.nix;

  # node-canvas builds code that requires aligned_alloc,
  # which on Darwin requires at least the 10.15 SDK
  stdenv' =
    if stdenv.hostPlatform.isDarwin
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

    postPatch = ''
      substituteInPlace webpack.common.js --replace-fail \
          "git describe --always --dirty" \
          "echo ${jellyfin-web-src.rev}"
    '';

    npmDepsHash = import ./npmDepsHash.nix;

    preBuild = ''
      # using sass-embedded fails at executing node_modules/sass-embedded-linux-x64/dart-sass/src/dart
      rm -r node_modules/sass-embedded*
    '';

    npmBuildScript = ["build:production"];

    nativeBuildInputs = [pkg-config] ++ optionals stdenv.hostPlatform.isDarwin [xcbuild];

    buildInputs =
      [pango]
      ++ optionals stdenv.hostPlatform.isDarwin [
        giflib
        darwin.apple_sdk.frameworks.CoreText
      ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      cp -a dist $out/share/jellyfin-web

      runHook postInstall
    '';

    postInstall = optionalString forceEnableBackdrops ''
      letter=$(sed -n 's/.*enableBackdrops:function...return.\(.\).*/\1/p' $out/share/jellyfin-web/main.jellyfin.bundle.js)

      substituteInPlace $out/share/jellyfin-web/main.jellyfin.bundle.js --replace-fail \
          "enableBackdrops:function(){return $letter}" "enableBackdrops:function(){return _}"
    '';

    meta = with lib; {
      description = "Web Client for Jellyfin";
      homepage = "https://jellyfin.org/";
      license = licenses.gpl2Plus;
    };
  }
