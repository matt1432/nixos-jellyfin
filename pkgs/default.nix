{
  pkgs,
  self,
  system,
  ...
}: {
  jellyfin-web = pkgs.callPackage ./jellyfin-web {};

  jellyfin = pkgs.callPackage ./jellyfin {
    inherit (self.packages.${system}) jellyfin-web;
  };

  jellyfin-ffmpeg = pkgs.callPackage ./jellyfin-ffmpeg {};

  # Not sure if this actually does anything
  cudaPackages = {
    jellyfin-web = pkgs.cudaPackages.callPackage ./jellyfin-web {};

    jellyfin = pkgs.cudaPackages.callPackage ./jellyfin {
      inherit (self.packages.${system}.cudaPackages) jellyfin-web;
    };

    jellyfin-ffmpeg = pkgs.cudaPackages.callPackage ./jellyfin-ffmpeg {};
  };
}
