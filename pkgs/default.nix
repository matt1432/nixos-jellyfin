final: prev: {
  jellyfin-web = final.callPackage ./jellyfin-web {};

  jellyfin = final.callPackage ./jellyfin {};

  jellyfin-ffmpeg = final.callPackage ./jellyfin-ffmpeg {};
  jellyfin-ffmpeg-cuda = final.cudaPackages.callPackage ./jellyfin-ffmpeg {fromCUDA = true;};

  # FIXME: uses insecure packages
  # jellyfin-media-player = final.callPackage ./jellyfin-media-player ({} // final.qt5);
}
