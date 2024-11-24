{
  lib,
  buildNpmPackage,
  darwin,
  fetchFromGitHub,
  giflib,
  nix-update-script,
  overrideSDK,
  pango,
  pkg-config,
  stdenv,
  xcbuild,
  # Options as overrides
  forceEnableBackdrops ? false,
}: let
  inherit (lib) concatStringsSep optionals optionalString;

  pname = "jellyfin-web";
  version = "10.10.3";

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
      hash = "sha256-xmy2cr6MJSen6Pok3Wde4mBcu5pM4qtGEBfqMpGdAxY=";
    };

    npmDepsHash = "sha256-qzjniTbJRNeZ2WFu8RBjcdZR96nvGRHMERdEiELLufg=";

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

    passthru.updateScript = concatStringsSep " " (nix-update-script {
      extraArgs = ["--flake" pname];
    });

    meta = with lib; {
      description = "Web Client for Jellyfin";
      homepage = "https://jellyfin.org/";
      license = licenses.gpl2Plus;
    };
  }
