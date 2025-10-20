{
  fetchFromGitHub,
  fetchpatch2,
  ffmpeg_7-full,
  lib,
  fromCUDA ? false,
  ...
}: let
  inherit (lib) optionals;

  pname = "jellyfin-ffmpeg";
  version = "7.1.2-3";
in
  (ffmpeg_7-full.override {
    inherit version; # Important! This sets the ABI.

    source = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-2+WGsGtT7X5F1bsdvbfFnz+EFOX7KC2MAsmXLreulnI=";
    };

    withUnfree = fromCUDA;
  })
  .overrideAttrs (old: {
    inherit pname;

    configureFlags =
      old.configureFlags
      ++ [
        "--extra-version=Jellyfin"
        "--disable-ptx-compression" # https://github.com/jellyfin/jellyfin/issues/7944#issuecomment-1156880067
      ];

    # Clobber upstream patches as they don't apply to the Jellyfin fork
    # except cuda patch
    patches =
      [
        (fetchpatch2 {
          name = "lcevcdec-4.0.0-compat.patch";
          url = "https://code.ffmpeg.org/FFmpeg/FFmpeg/commit/fa23202cc7baab899894e8d22d82851a84967848.patch";
          hash = "sha256-Ixkf1xzuDGk5t8J/apXKtghY0X9cfqSj/q987zrUuLQ=";
        })
      ]
      ++ optionals fromCUDA [./nvccflags-cpp14.patch];

    postPatch = ''
      for file in $(cat debian/patches/series); do
        patch -p1 < debian/patches/$file
      done

      ${old.postPatch or ""}
    '';

    meta = {
      inherit (old.meta) license mainProgram;
      changelog = "https://github.com/jellyfin/jellyfin-ffmpeg/releases/tag/v${version}";
      description = "${old.meta.description} (Jellyfin fork)";
      homepage = "https://github.com/jellyfin/jellyfin-ffmpeg";
      pkgConfigModules = ["libavutil"];
    };
  })
