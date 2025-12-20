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
  version = "7.1.3-1";
in
  (ffmpeg_7-full.override {
    inherit version; # Important! This sets the ABI.

    source = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-ZODAY7ahap6PWGKwQPWh+YOYo8hUKiQLED36uJcyt/U=";
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
        (fetchpatch2 {
          name = "unbreak-hardcoded-tables.patch";
          url = "https://git.ffmpeg.org/gitweb/ffmpeg.git/patch/1d47ae65bf6df91246cbe25c997b25947f7a4d1d";
          hash = "sha256-ulB5BujAkoRJ8VHou64Th3E94z6m+l6v9DpG7/9nYsM=";
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
