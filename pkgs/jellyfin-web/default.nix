{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
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
  version = "12.0";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-web";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LwFjfG+OLgQDP7GqD4/wQhmym4N5QWe/qITQN+hxHh8=";
  };

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

  npmDepsHash = "sha256-1s9PWqakzZMiZokOqnKfwaj9s7yWm6e/xh4R5OmTNMc=";

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
