final: prev: {
  jellyfin-web = final.callPackage ./jellyfin-web {};

  jellyfin = final.callPackage ./jellyfin {};

  jellyfin-ffmpeg = final.callPackage ./jellyfin-ffmpeg {};
  jellyfin-ffmpeg-cuda = final.cudaPackages.callPackage ./jellyfin-ffmpeg {fromCUDA = true;};

  jellyfin-desktop = final.kdePackages.callPackage ./jellyfin-desktop {};
}
