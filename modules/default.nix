jellyPkgs: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    boolToString
    concatStringsSep
    concatMapStringsSep
    literalExpression
    mkDefault
    mkForce
    mkIf
    mkOption
    optionalString
    types
    ;
  inherit (builtins) isNull;

  cfg = config.services.jellyfin;

  mkEmptyDefault = opt: name:
    if isNull opt
    then "<${name} />"
    else "<${name}>${opt}</${name}>";

  mkBool = opt: name: "<${name}>${boolToString opt}</${name}>";

  indent = "  ";
  indent2 = "${indent}${indent}";

  mkStringArray = opt: name: ind:
    if isNull opt
    then "${optionalString ind indent2}${indent}<${name} />"
    else ''
      ${optionalString ind indent2}${indent}<${name}>
      ${concatMapStringsSep "\n"
        (x: "  ${optionalString ind indent2}${indent}<string>${x}</string>")
        opt}
      ${optionalString ind indent2}${indent}</${name}>'';

  mkPluginRepoInfo = repo: ''
    ${indent2}<RepositoryInfo>
    ${indent2}${indent}<Name>${repo.name}</Name>
    ${indent2}${indent}<Url>${repo.url}</Url>
    ${indent2}${indent}<Enabled>${boolToString repo.enable}</Enabled>
    ${indent2}</RepositoryInfo>'';

  mkMetadataOptions = meta: ''
    ${indent2}<MetadataOptions>
      ${indent2}<ItemType>${meta.itemType}</ItemType>
    ${mkStringArray meta.disabledMetadataSavers "DisabledMetadataSavers" true}
    ${mkStringArray meta.localMetadataReaderOrder "LocalMetadataReaderOrder" true}
    ${mkStringArray meta.disabledMetadataFetchers "DisabledMetadataFetchers" true}
    ${mkStringArray meta.metadataFetcherOrder "MetadataFetcherOrder" true}
    ${mkStringArray meta.disabledImageFetchers "DisabledImageFetchers" true}
    ${mkStringArray meta.imageFetcherOrder "ImageFetcherOrder" true}
    ${indent2}</MetadataOptions>'';

  importXML = file: cfg:
    pkgs.writeTextFile {
      name = "${file}.xml";
      text = import ./templates/${file}.nix {
        inherit
          cfg
          lib
          mkBool
          mkEmptyDefault
          mkMetadataOptions
          mkStringArray
          mkPluginRepoInfo
          ;
      };
    };

  mkConfigSetup = file: name: ''
    backupFile "${cfg.configDir}/${name}.xml"
    cp -rf ${file} "${cfg.configDir}/${name}.xml"
    chmod 600 "${cfg.configDir}/${name}.xml"
  '';

  brandingFile = importXML "branding" cfg.settings.branding;
  encodingFile = importXML "encoding" cfg.settings.encoding;
  metadataFile = importXML "metadata" cfg.settings.metadata;
  systemFile = importXML "system" cfg.settings.system;
in {
  options.services.jellyfin = {
    webPackage = mkOption {
      type = types.package;
      default = jellyPkgs.${pkgs.system}.jellyfin-web;
      defaultText = literalExpression "nixos-jellyfin.packages.x86_64-linux.jellyfin-web";
      example = literalExpression ''
        nixos-jellyfin.packages.x86_64-linux.jellyfin-web.override {
          forceEnableBackdrops = true;
        }
      '';
      description = ''
        The jellyfin-web package to use.\
        By default, this option will use the `packages.jellyfin-web` as exposed by this flake.
      '';
    };

    ffmpegPackage = mkOption {
      type = types.package;
      default = jellyPkgs.${pkgs.system}.jellyfin-ffmpeg;
      defaultText = literalExpression "nixos-jellyfin.packages.x86_64-linux.jellyfin-ffmpeg";
      description = ''
        The jellyfin-ffmpeg package to use.\
        By default, this option will use the `packages.jellyfin-ffmpeg` as exposed by this flake.
      '';
    };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      default = cfg.package.override {
        jellyfin-ffmpeg = cfg.ffmpegPackage;
      };
      defaultText = literalExpression ''
        nixos-jellyfin.packages.x86_64-linux.jellyfin.override {
          ffmpeg = nixos-jellyfin.packages.x86_64-linux.jellyfin-ffmpeg;
        }
      '';
      description = ''
        The package defined by `services.jellyfin.package` with overrides applied.
      '';
    };

    settings = mkOption {
      default = null;
      type = types.nullOr (types.submodule {
        options = {
          # Organized by config file
          branding = import ./options/branding-options.nix {
            inherit lib;
          };

          encoding = import ./options/encoding-options.nix {
            inherit lib;
            jellyConfig = cfg;
            ffmpeg = cfg.ffmpegPackage;
            cfg = cfg.settings.encoding;
          };

          metadata = import ./options/metadata-config.nix {
            inherit lib;
          };

          system =
            (import ./options/server-config.nix {
              inherit config lib;
              jellyConfig = cfg;
            })
            // (import ./options/base-app-config.nix {
              inherit lib;
            });
        };
      });
    };
  };

  config = mkIf (cfg.enable && cfg.settings != null) {
    services.jellyfin.package = mkDefault jellyPkgs.${pkgs.system}.jellyfin;

    environment.systemPackages = with cfg; [
      finalPackage
      webPackage
      ffmpegPackage
    ];

    systemd.services."jellyfin" = {
      restartTriggers = [(builtins.toJSON cfg.settings)];

      preStart = ''
        # Make jellyfin-web read/write
        chmod u+w -R "${cfg.dataDir}/jellyfin-web"
        rm -rf ${cfg.dataDir}/jellyfin-web
        cp -r ${cfg.webPackage}/share/jellyfin-web ${cfg.dataDir}

        backupFile() {
            if [ -w "$1" ]; then
                rm -f "$1.bak"
                mv "$1" "$1.bak"
            fi
        }

        ${concatMapStringsSep "\n" (x: mkConfigSetup x.file x.name) [
          {
            file = brandingFile;
            name = "branding";
          }
          {
            file = encodingFile;
            name = "encoding";
          }
          {
            file = systemFile;
            name = "system";
          }
          {
            file = metadataFile;
            name = "metadata";
          }
        ]}

        chmod u+w -R "${cfg.dataDir}/jellyfin-web"
      '';

      serviceConfig.ExecStart = mkForce (concatStringsSep " " [
        "${cfg.finalPackage}/bin/jellyfin"
        "--datadir '${cfg.dataDir}'"
        "--configdir '${cfg.configDir}'"
        "--cachedir '${cfg.cacheDir}'"
        "--logdir '${cfg.logDir}'"
        "--ffmpeg '${cfg.ffmpegPackage}/bin/ffmpeg'"
        "--webdir '${cfg.dataDir}/jellyfin-web'"
      ]);
    };
  };
}
