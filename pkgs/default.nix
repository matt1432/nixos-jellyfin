{
  pkgs,
  self,
  ...
}: {
  jellyfin-web = pkgs.callPackage ./jellyfin-web {};

  jellyfin = pkgs.callPackage ./jellyfin {};

  jellyfin-ffmpeg = pkgs.callPackage ./jellyfin-ffmpeg {};

  jellyfin-media-player = pkgs.callPackage ./jellyfin-media-player {
    inherit (self.packages.${pkgs.system}) jellyfin-web;
  };

  # Not sure if this actually does anything
  cudaPackages = {
    jellyfin-web = pkgs.cudaPackages.callPackage ./jellyfin-web {};

    jellyfin = pkgs.cudaPackages.callPackage ./jellyfin {};

    jellyfin-ffmpeg = pkgs.cudaPackages.callPackage ./jellyfin-ffmpeg {};
  };
}
