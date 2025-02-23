{
  pkgs,
  self,
  cudaPkgs,
  ...
}: {
  jellyfin-web = pkgs.callPackage ./jellyfin-web {};

  jellyfin = pkgs.callPackage ./jellyfin {};

  jellyfin-ffmpeg = pkgs.callPackage ./jellyfin-ffmpeg {};

  jellyfin-media-player = pkgs.callPackage ./jellyfin-media-player {
    inherit (self.packages.${pkgs.system}) jellyfin-web;
  };

  cudaPackages = let
    cudaCallPackage = file: attrs: cudaPkgs.cudaPackages.callPackage file ({} // attrs // {fromCUDA = true;});
  in {
    jellyfin-ffmpeg = cudaCallPackage ./jellyfin-ffmpeg {};
  };
}
