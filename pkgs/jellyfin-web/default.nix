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
  ...
}:
buildNpmPackage (finalAttrs: {
  pname = "jellyfin-web";
  version = "10.11.6";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-web";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qmpVuxwsMM9Fhjkrrkxh+pMDh6+c3rZde7in5vIpaDg=";
  };

  nodejs = nodejs_20; # https://github.com/NixOS/nixpkgs/blob/95879b2866c0517cea97ed12ef5d812d5485995e/pkgs/by-name/je/jellyfin-web/package.nix#L29

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

  npmDepsHash = "sha256-bXZn2FOWeIN8VTNLbKe7jM7yDtE2QRmyoWNZXgE5W4Q=";

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
