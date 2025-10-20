{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_20,
  pkg-config,
  xcbuild,
  pango,
  giflib,
  # Options as overrides
  forceEnableBackdrops ? false,
  forceDisablePreferFmp4 ? false,
}: let
  inherit (lib) optionals optionalString;

  pname = "jellyfin-web";
  version = "10.11.0";
in
  buildNpmPackage {
    inherit pname version;

    nodejs = nodejs_20; # https://github.com/NixOS/nixpkgs/blob/95879b2866c0517cea97ed12ef5d812d5485995e/pkgs/by-name/je/jellyfin-web/package.nix#L29

    src = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-LcZNfFXM2dFHeUheSnri1t4eBYvlCfF2wlaqWlh+U7A=";
    };

    npmDepsHash = "sha256-w3xMbkxNGFEBR2K1PhJW6pr943DfJvyQvILiF0VuLlw=";

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
      ''
      + optionalString forceDisablePreferFmp4 ''
        substituteInPlace src/scripts/settings/userSettings.js --replace-fail \
            "return toBoolean(this.get('preferFmp4HlsContainer', false), browser.safari || browser.firefox || browser.chrome || browser.edgeChromium);" \
            "return toBoolean(this.get('preferFmp4HlsContainer', false), false);"
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
