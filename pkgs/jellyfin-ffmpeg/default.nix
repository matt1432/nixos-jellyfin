{
  fetchFromGitHub,
  ffmpeg_8-full,
  fromCUDA ? false,
  ...
}: let
  pname = "jellyfin-ffmpeg";
  version = "8.1.2-2";
in
  (ffmpeg_8-full.override {
    inherit version; # Important! This sets the ABI.

    source = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-3RrDxorn4ZeLfFxvTg3szIqCwOueivdFkSfu+Jh7oco=";
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

    meta = {
      inherit (old.meta) license mainProgram;
      changelog = "https://github.com/jellyfin/jellyfin-ffmpeg/releases/tag/v${version}";
      description = "${old.meta.description} (Jellyfin fork)";
      homepage = "https://github.com/jellyfin/jellyfin-ffmpeg";
      pkgConfigModules = ["libavutil"];
    };
  })
