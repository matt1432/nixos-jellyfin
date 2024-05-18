{
  lib,
  dotnetCorePackages,
  buildDotnetModule,
  ffmpeg,
  fontconfig,
  freetype,
  jellyfin-src,
  jellyfin-web,
  sqlite,
}:
buildDotnetModule rec {
  pname = "jellyfin";
  version =
    lib.removePrefix
    "v"
    ((builtins.fromJSON (builtins.readFile ../flake.lock))
      .nodes
      .jellyfin-src
      .original
      .ref);

  src = jellyfin-src;

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

  preInstall = ''
    makeWrapperArgs+=(
      --add-flags "--ffmpeg ${ffmpeg}/bin/ffmpeg"
      --add-flags "--webdir ${jellyfin-web}/share/jellyfin-web"
    )
  '';

  meta = {
    description = "The Free Software Media System";
    homepage = "https://jellyfin.org/";
    # https://github.com/jellyfin/jellyfin/issues/610#issuecomment-537625510
    license = lib.licenses.gpl2Plus;
    mainProgram = "jellyfin";
    platforms = dotnet-runtime.meta.platforms;
  };
}
