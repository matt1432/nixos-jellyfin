{
  lib,
  fetchFromGitHub,
  stdenv,
  cmake,
  ninja,
  python3,
  wrapQtAppsHook,
  qtbase,
  qtdeclarative,
  qtwebchannel,
  qtwebengine,
  mpv-unwrapped,
  mpvqt,
  libcec,
  SDL2,
  libXrandr,
}: let
  pname = "jellyfin-desktop";
  version = "2.0.0";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "jellyfin";
      repo = "jellyfin-desktop";
      rev = "v${version}";
      hash = "sha256-ITlYOrMS6COx9kDRSBi4wM6mzL/Q2G5X9GbABwDIOe4=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [
      cmake
      ninja
      python3
      wrapQtAppsHook
    ];

    buildInputs =
      [
        qtbase
        qtdeclarative
        qtwebchannel
        qtwebengine
        mpv-unwrapped

        # input sources
        libcec
        SDL2

        # frame rate switching
        libXrandr
      ]
      ++ lib.optional (!stdenv.hostPlatform.isDarwin) mpvqt;

    cmakeFlags =
      [
        "-DCHECK_FOR_UPDATES=OFF"
        # workaround for Qt cmake weirdness
        "-DQT_DISABLE_NO_DEFAULT_PATH_IN_QT_PACKAGES=ON"
      ]
      ++ lib.optional stdenv.hostPlatform.isDarwin "-DUSE_STATIC_MPVQT=ON"
      ++ lib.optional (!stdenv.hostPlatform.isDarwin) "-DUSE_STATIC_MPVQT=OFF";

    postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/bin $out/Applications
      mv "$out/Jellyfin Desktop.app" $out/Applications
      ln -s "$out/Applications/Jellyfin Desktop.app/Contents/MacOS/Jellyfin Desktop" $out/bin/jellyfindesktop
    '';

    meta = {
      homepage = "https://github.com/jellyfin/jellyfin-desktop";
      description = "Jellyfin Desktop Client";
      license = with lib.licenses; [
        gpl2Only
        mit
      ];
      platforms = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      mainProgram = pname;
    };
  }
