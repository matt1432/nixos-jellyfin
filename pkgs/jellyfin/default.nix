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
  version = "10.10.4";
in
  buildDotnetModule rec {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-L/h2TfRsOxWFK6O3lh5BusWOyxuKpvhimH/wANIT0vA=";
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
    nugetDeps = ./nuget-deps.json;
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
