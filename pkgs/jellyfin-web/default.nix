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
  # Options as overrides
  forceEnableBackdrops ? false,
}: let
  inherit (lib) optionals optionalString;

  pname = "jellyfin-web";
  version = "10.10.2";

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
    inherit pname version;

    src = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-IAe5VlrJkwsa3fs3RB+gnYnZFM/nRjERIXEjwyKEYLI=";
    };

    npmDepsHash = "sha256-TTNS/KxRJUqqwdF8tZwhNokBAJXPQ+J45tmUJlgcJIY=";

    postPatch =
      ''
        substituteInPlace webpack.common.js --replace-fail \
            "git describe --always --dirty" \
            "echo v${version}"
      ''
      + optionalString forceEnableBackdrops ''
        substituteInPlace src/scripts/settings/userSettings.js --replace-fail \
            "return toBoolean(this.get('enableBackdrops', false), false);" \
            "return toBoolean(this.get('enableBackdrops', false), true);"
      '';

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

    meta = with lib; {
      description = "Web Client for Jellyfin";
      homepage = "https://jellyfin.org/";
      license = licenses.gpl2Plus;
    };
  }
