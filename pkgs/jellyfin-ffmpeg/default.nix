{
  fetchFromGitHub,
  ffmpeg_7-full,
  lib,
}: let
  jellyfin-ffmpeg-src = import ./src.nix;

  version = lib.removePrefix "v" jellyfin-ffmpeg-src.rev;
in
  (ffmpeg_7-full.override {
    inherit version; # Important! This sets the ABI.
    source = fetchFromGitHub jellyfin-ffmpeg-src;

    # FIXME: https://pr-tracker.nelim.org/?pr=353198
    withXevd = false;
    withXeve = false;
  })
  .overrideAttrs (old: {
    pname = "jellyfin-ffmpeg";

    # Clobber upstream patches as they don't apply to the Jellyfin fork
    patches = [];

    postPatch = ''
      for file in $(cat debian/patches/series); do
        patch -p1 < debian/patches/$file
      done

      ${old.postPatch or ""}
    '';

    meta = {
      description = "${old.meta.description} (Jellyfin fork)";
      homepage = "https://github.com/jellyfin/jellyfin-ffmpeg";
      license = lib.licenses.gpl3;
      pkgConfigModules = ["libavutil"];
    };
  })
