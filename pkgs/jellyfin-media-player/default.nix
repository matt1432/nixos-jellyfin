{
  lib,
  fetchFromGitHub,
  fetchpatch,
  stdenv,
  SDL2,
  cmake,
  libGL,
  libX11,
  libXrandr,
  libvdpau,
  mpv,
  ninja,
  pkg-config,
  python3,
  qtbase,
  qtwayland,
  qtwebchannel,
  qtwebengine,
  qtx11extras,
  jellyfin-web,
  # Options as overrides
  withDbus ? stdenv.hostPlatform.isLinux,
  ...
}: let
  inherit (lib) optionals optionalString;

  pname = "jellyfin-media-player";
  version = "1.12.0";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "jellyfin";
      repo = "jellyfin-media-player";
      rev = "v${version}";
      hash = "sha256-IXinyenadnW+a+anQ9e61h+N8vG2r77JPboHm5dN4Iw=";
    };

    patches = [
      # fix the location of the jellyfin-web path
      ./fix-web-path.patch
      # disable update notifications since the end user can't simply download the release artifacts to update
      ./disable-update-notifications.patch

      # cmake 4 compatibility
      (fetchpatch {
        url = "https://github.com/jellyfin/jellyfin-media-player/commit/6c5c603a1db489872832ed560581d98fdee89d6f.patch";
        hash = "sha256-Blq7y7kOygbZ6uKxPJl9aDXJWqhE0jnM5GNEAwyQEA0=";
      })
    ];

    buildInputs =
      [
        SDL2
        libGL
        libX11
        libXrandr
        libvdpau
        mpv
        qtbase
        qtwebchannel
        qtwebengine
        qtx11extras
      ]
      ++ optionals stdenv.hostPlatform.isLinux [
        qtwayland
      ];

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      python3
    ];

    cmakeFlags =
      [
        "-DQTROOT=${qtbase}"
        "-GNinja"
      ]
      ++ optionals (!withDbus) [
        "-DLINUX_X11POWER=ON"
      ];

    preConfigure = ''
      # link the jellyfin-web files to be copied by cmake (see fix-web-path.patch)
      ln -s ${jellyfin-web}/share/jellyfin-web .
    '';

    postInstall = optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/bin $out/Applications
      mv "$out/Jellyfin Media Player.app" $out/Applications
      ln -s "$out/Applications/Jellyfin Media Player.app/Contents/MacOS/Jellyfin Media Player" $out/bin/jellyfinmediaplayer
    '';

    meta = {
      homepage = "https://github.com/jellyfin/jellyfin-media-player";
      description = "Jellyfin Desktop Client based on Plex Media Player";
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
      mainProgram = "jellyfinmediaplayer";
    };
  }
