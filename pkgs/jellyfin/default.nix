{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  fontconfig,
  freetype,
  jellyfin-ffmpeg,
  sqlite,
  ...
}: let
  pname = "jellyfin";
  version = "10.11.3";
in
  buildDotnetModule rec {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "jellyfin";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-xNQe0hjY1BjC1D+hYTj1Gv2jCpwhWJv9dlvY6K9jkSk=";
    };

    propagatedBuildInputs = [
      sqlite
    ];

    projectFile = "Jellyfin.Server/Jellyfin.Server.csproj";
    executables = ["jellyfin"];
    nugetDeps = ./nuget-deps.json;
    runtimeDeps = [
      fontconfig
      freetype
      jellyfin-ffmpeg
    ];
    dotnet-sdk = dotnetCorePackages.sdk_9_0;
    dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;
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
