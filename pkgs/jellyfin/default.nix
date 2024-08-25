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
  jellyfin-src = import ./src.nix;
in
  buildDotnetModule rec {
    pname = "jellyfin";
    version = lib.removePrefix "v" jellyfin-src.rev;

    src = fetchFromGitHub jellyfin-src;

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

    meta = {
      description = "The Free Software Media System";
      homepage = "https://jellyfin.org/";
      # https://github.com/jellyfin/jellyfin/issues/610#issuecomment-537625510
      license = lib.licenses.gpl2Plus;
      mainProgram = "jellyfin";
      platforms = dotnet-runtime.meta.platforms;
    };
  }
