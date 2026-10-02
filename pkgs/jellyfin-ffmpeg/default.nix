{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  ffmpeg_8-full,
  fromCUDA ? false,
  ...
}: let
  inherit (lib) remove;

  pname = "jellyfin-ffmpeg";
  version = "8.1.3-1";

  swScalePatch = fetchpatch2 {
    url = "https://salsa.debian.org/multimedia-team/ffmpeg/-/raw/d52aea25bc9123bfaf61f7a7e5a0d9da01c8788d/debian/patches/0001-swscale-loongarch-fix-buffer-underflow-in-yuv2plane1.patch";
    hash = "sha256-QRkb7z4Btyd9ZgV/1hh6Fb87IhkygFgVDqQdloXKL6Q=";
  };
in
  (ffmpeg_8-full.override {
    inherit version; # Important! This sets the ABI.

    source = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-sxJyUaB0rqpVzd6OVRC6kPVWyBdgFUzvyqwLCkMKRgM=";
    };

    withUnfree = fromCUDA;
    withCudaLLVM = false; # Fails to build with clang
  })
  .overrideAttrs (old: {
    inherit pname;

    configureFlags =
      old.configureFlags
      ++ [
        "--extra-version=Jellyfin"
      ];

    postPatch = ''
      for file in $(cat debian/patches/series); do
        patch -p1 < debian/patches/$file
      done

      ${old.postPatch or ""}
    '';

    patches = remove swScalePatch old.patches;

    meta = {
      inherit (old.meta) license mainProgram;
      changelog = "https://github.com/jellyfin/jellyfin-ffmpeg/releases/tag/v${version}";
      description = "${old.meta.description} (Jellyfin fork)";
      homepage = "https://github.com/jellyfin/jellyfin-ffmpeg";
      pkgConfigModules = ["libavutil"];
    };
  })
