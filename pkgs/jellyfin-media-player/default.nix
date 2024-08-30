{
  lib,
  fetchFromGitHub,
  stdenv,
  Cocoa ? null,
  CoreAudio ? null,
  CoreFoundation ? null,
  MediaPlayer ? null,
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
  qt5,
  jellyfin-web,
  withDbus ? stdenv.isLinux,
  isNvidiaWayland ? false,
  makeWrapper,
}: let
  inherit (lib) optionals optionalString removePrefix;

  jellyfin-media-player-src = import ./src.nix;
in
  stdenv.mkDerivation {
    pname = "jellyfin-media-player";
    version = removePrefix "v" jellyfin-media-player-src.rev;

    src = fetchFromGitHub jellyfin-media-player-src;

    patches = [
      # fix the location of the jellyfin-web path
      ./fix-web-path.patch
      # disable update notifications since the end user can't simply download the release artifacts to update
      ./disable-update-notifications.patch
    ];

    buildInputs =
      [
        SDL2
        libGL
        libX11
        libXrandr
        libvdpau
        mpv
        qt5.qtbase
        qt5.qtwebchannel
        qt5.qtwebengine
        qt5.qtx11extras
      ]
      ++ optionals isNvidiaWayland [
        makeWrapper
      ]
      ++ optionals stdenv.isLinux [
        qt5.qtwayland
      ]
      ++ optionals stdenv.isDarwin [
        Cocoa
        CoreAudio
        CoreFoundation
        MediaPlayer
      ];

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      python3
      qt5.wrapQtAppsHook
    ];

    cmakeFlags =
      [
        "-DQTROOT=${qt5.qtbase}"
        "-GNinja"
      ]
      ++ optionals (!withDbus) [
        "-DLINUX_X11POWER=ON"
      ];

    preConfigure = ''
      # link the jellyfin-web files to be copied by cmake (see fix-web-path.patch)
      ln -s ${jellyfin-web}/share/jellyfin-web .
    '';

    postInstall =
      (optionalString stdenv.isDarwin ''
        mkdir -p $out/bin $out/Applications
        mv "$out/Jellyfin Media Player.app" $out/Applications

        # move web-client resources
        mv $out/Resources/* "$out/Applications/Jellyfin Media Player.app/Contents/Resources/"
        rmdir $out/Resources

        ln -s "$out/Applications/Jellyfin Media Player.app/Contents/MacOS/Jellyfin Media Player" $out/bin/jellyfinmediaplayer
      '')
      + (optionalString isNvidiaWayland ''
        wrapProgram $out/bin/jellyfinmediaplayer \
            --add-flags "--platform xcb"
      '');

    meta = with lib; {
      homepage = "https://github.com/jellyfin/jellyfin-media-player";
      description = "Jellyfin Desktop Client based on Plex Media Player";
      license = with licenses; [gpl2Only mit];
      platforms = ["aarch64-linux" "x86_64-linux" "x86_64-darwin"];
      mainProgram = "jellyfinmediaplayer";
    };
  }
