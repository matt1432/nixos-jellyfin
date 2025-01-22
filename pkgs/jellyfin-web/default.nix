{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_20,
  nix-update-script,
  pkg-config,
  xcbuild,
  pango,
  giflib,
  apple-sdk_11,
  darwinMinVersionHook,
  # Options as overrides
  forceEnableBackdrops ? false,
  forceDisablePreferFmp4 ? false,
}: let
  inherit (lib) concatStringsSep optionals optionalString;

  pname = "jellyfin-web";
  version = "10.10.4";
in
  buildNpmPackage {
    inherit pname version;

    nodejs = nodejs_20; # https://github.com/NixOS/nixpkgs/blob/95879b2866c0517cea97ed12ef5d812d5485995e/pkgs/by-name/je/jellyfin-web/package.nix#L29

    src = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-j5Tl0ORefRPemFO78EvCPmXMKWTsneUsRODQBIA7AdE=";
    };

    npmDepsHash = "sha256-psF/ixahZSgjCeRJHVA+4Xf9UuHY/a2dyhwUQDZois4=";

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
        apple-sdk_11
        # node-canvas builds code that requires aligned_alloc,
        # which on Darwin requires at least the 10.15 SDK
        (darwinMinVersionHook "10.15")
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
