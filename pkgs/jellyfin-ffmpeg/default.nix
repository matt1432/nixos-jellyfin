{
  fetchFromGitHub,
  ffmpeg_7-full,
  lib,
  nix-update-script,
  fromCUDA ? false,
  ...
}: let
  inherit (lib) concatStringsSep;

  pname = "jellyfin-ffmpeg";
  version = "7.1.1-3";
in
  (ffmpeg_7-full.override {
    inherit version; # Important! This sets the ABI.

    source = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-pJLIhXDPDRhEqzmc1bXViSTSnRifFhMlixkEbGA0GRE=";
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

    postPatch = ''
      for file in $(cat debian/patches/series); do
        patch -p1 < debian/patches/$file
      done

      ${old.postPatch or ""}
    '';

    passthru.updateScript = concatStringsSep " " (nix-update-script {
      extraArgs = [
        "--flake"
        pname
        "--override-filename"
        "./pkgs/jellyfin-ffmpeg/default.nix"
      ];
    });

    meta = {
      inherit (old.meta) license mainProgram;
      changelog = "https://github.com/jellyfin/jellyfin-ffmpeg/releases/tag/v${version}";
      description = "${old.meta.description} (Jellyfin fork)";
      homepage = "https://github.com/jellyfin/jellyfin-ffmpeg";
      pkgConfigModules = ["libavutil"];
    };
  })
