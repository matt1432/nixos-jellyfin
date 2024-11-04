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

    configureFlags =
      old.configureFlags
      ++ [
        "--extra-version=Jellyfin"
        "--disable-ptx-compression" # https://github.com/jellyfin/jellyfin/issues/7944#issuecomment-1156880067
      ];

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
