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
  version = "7.1.4-1";
in
  (ffmpeg_7-full.override {
    inherit version; # Important! This sets the ABI.

    source = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-VijSSbtcaeQNf1UwpPKTIfzAHHp2BHvBdhXeigTQEbI=";
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
