{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_22,
  pkg-config,
  xcbuild,
  pango,
  giflib,
  # Options as overrides
  forceEnableBackdrops ? false,
  forceDisablePreferFmp4 ? false,
  ...
}:
buildNpmPackage (finalAttrs: {
  pname = "jellyfin-web";
  version = "10.11.11";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-web";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3Gyg0eSbOXO0wgdgzuOtD8nDmSM37z7Bc0fKcbo9ffA=";
  };

  nodejs = nodejs_22;

  postPatch =
    # bash
    ''
      substituteInPlace webpack.common.js \
        --replace-fail "git describe --always --dirty" "echo ${finalAttrs.src.rev}"
    ''
    + lib.optionalString forceEnableBackdrops
    # bash
    ''
      substituteInPlace src/scripts/settings/userSettings.js --replace-fail \
          "return toBoolean(this.get('enableBackdrops', false), false);" \
          "return toBoolean(this.get('enableBackdrops', false), true);"
    ''
    + lib.optionalString forceDisablePreferFmp4
    # bash
    ''
      substituteInPlace src/scripts/settings/userSettings.js --replace-fail \
          "return toBoolean(this.get('preferFmp4HlsContainer', false), browser.safari || browser.firefox || browser.chrome || browser.edgeChromium);" \
          "return toBoolean(this.get('preferFmp4HlsContainer', false), false);"
    '';

  npmDepsHash = "sha256-4kZo50xY/SvjpHToeIt0E91yeM7ab6Q6XtBMU5zSrF4=";

  preBuild = ''
    # using sass-embedded fails at executing node_modules/sass-embedded-linux-x64/dart-sass/src/dart
    rm -r node_modules/sass-embedded*
  '';

  npmBuildScript = ["build:production"];

  nativeBuildInputs = [pkg-config] ++ lib.optionals stdenv.hostPlatform.isDarwin [xcbuild];

  buildInputs =
    [
      pango
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      giflib
    ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -a dist $out/share/jellyfin-web

    runHook postInstall
  '';

  meta = {
    description = "Web Client for Jellyfin";
    homepage = "https://jellyfin.org/";
    license = lib.licenses.gpl2Plus;
  };
})
