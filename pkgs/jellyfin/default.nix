{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  ffmpeg,
  fontconfig,
  freetype,
  sqlite,
}: let
  pname = "jellyfin";
  version = "10.10.2";
in
  buildDotnetModule rec {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-tA9Jr6X6LzntHTJ+U4ZuA1bs8K6YCMvlbhiWvK8mMn8=";
    };

    postPatch = ''
      substituteInPlace global.json \
          --replace-fail "latestMinor" "latestRelease"
    '';

    propagatedBuildInputs = [
      sqlite
    ];

    projectFile = "Jellyfin.Server/Jellyfin.Server.csproj";
    executables = ["jellyfin"];
    nugetDeps = ./nuget-deps.nix;
    runtimeDeps = [
      ffmpeg
      fontconfig
      freetype
    ];
    dotnet-sdk = dotnetCorePackages.sdk_8_0;
    dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
    dotnetBuildFlags = ["--no-self-contained"];

    passthru.updateScript = ./update.sh;

    meta = {
      description = "The Free Software Media System";
      homepage = "https://jellyfin.org/";
      # https://github.com/jellyfin/jellyfin/issues/610#issuecomment-537625510
      license = lib.licenses.gpl2Plus;
      mainProgram = "jellyfin";
      platforms = dotnet-runtime.meta.platforms;
    };
  }
