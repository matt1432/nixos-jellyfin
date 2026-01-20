{
  lib,
  fetchFromGitHub,
  dotnetCorePackages,
  buildDotnetModule,
  jellyfin-ffmpeg,
  fontconfig,
  freetype,
  jellyfin-web,
  coreutils,
  sqlite,
  versionCheckHook,
  ...
}:
buildDotnetModule (finalAttrs: {
  pname = "jellyfin";
  version = "10.11.6";

  src = # assert finalAttrs.version == jellyfin-web.version;
    fetchFromGitHub {
      owner = "jellyfin";
      repo = "jellyfin";
      tag = "v${finalAttrs.version}";
      hash = "sha256-bF/N6FC1/qfBar2KNut8KY3Rz+pqArCt4HV3NAH8eaU=";
    };

  propagatedBuildInputs = [sqlite];

  projectFile = "Jellyfin.Server/Jellyfin.Server.csproj";
  executables = ["jellyfin"];
  nugetDeps = ./nuget-deps.json;
  runtimeDeps = [
    jellyfin-ffmpeg
    fontconfig
    freetype
  ];
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;
  dotnetBuildFlags = ["--no-self-contained"];

  makeWrapperArgs = [
    "--add-flags"
    "--ffmpeg=${jellyfin-ffmpeg}/bin/ffmpeg"
    "--add-flags"
    "--webdir=$webdir/jellyfin-web"
  ];

  # Make jellyfin-web writeable for some plugins
  preInstall = ''
    makeWrapperArgs+=(
      --run '
          PATH="$PATH:${coreutils}/bin"
          webdir=$(mktemp --tmpdir -d jellyfin-web.XXXXXX)
          trap "rm -rf $webdir" EXIT
          chmod a+rx "$webdir"
          cp -r ${jellyfin-web}/share/jellyfin-web "$webdir"
          chmod u+w -R "$webdir/jellyfin-web"
      '
    )
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Free Software Media System";
    homepage = "https://jellyfin.org/";
    # https://github.com/jellyfin/jellyfin/issues/610#issuecomment-537625510
    license = lib.licenses.gpl2Plus;
    mainProgram = "jellyfin";
    platforms = finalAttrs.dotnet-runtime.meta.platforms;
  };
})
