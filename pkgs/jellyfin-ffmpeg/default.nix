{
  fetchFromGitHub,
  ffmpeg_8-full,
  lib,
  fromCUDA ? false,
  ...
}: let
  inherit (lib) optionals;

  pname = "jellyfin-ffmpeg";
  version = "8.1.1-3";
in
  (ffmpeg_8-full.override {
    inherit version; # Important! This sets the ABI.

    source = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-Yu2hkEDIhlZhPoLYf0OiY6G+e/agb0RDv/sM6GKQsiU=";
    };

    withUnfree = fromCUDA;
  })
  .overrideAttrs (old: {
    inherit pname;

    configureFlags =
      old.configureFlags
      ++ [
        "--extra-version=Jellyfin"
      ];

    # Clobber upstream patches as they don't apply to the Jellyfin fork
    patches = [] ++ optionals fromCUDA [./nvccflags-cpp14.patch];

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
