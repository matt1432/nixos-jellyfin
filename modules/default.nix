{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    boolToString
    concatMapStringsSep
    mkIf
    mkOption
    optionalString
    types
    ;
  inherit (builtins) isNull;

  cfg = config.services.jellyfin;
  jellyConfig = config.systemd.services.jellyfin.serviceConfig;
  configDir = "${jellyConfig.WorkingDirectory}/config";
in {
  options.services.jellyfin = {
    settings = mkOption {
      default = null;
      type = with types;
        nullOr (submodule {
          options = {
            # Organized by config file
            branding = import ./options/branding-options.nix {
              inherit lib;
            };

            encoding = import ./options/encoding-options.nix {
              inherit lib pkgs jellyConfig;
              cfg = cfg.settings.encoding;
            };

            metadata = import ./options/metadata-config.nix {
              inherit lib;
            };

            system =
              (import ./options/server-config.nix {
                inherit config lib jellyConfig;
              })
              // (import ./options/base-app-config.nix {
                inherit lib;
              });
          };
        });
    };
  };

  config = mkIf (cfg.enable && cfg.settings != null) {
    systemd.services."jellyfin".restartTriggers = [(builtins.toJSON cfg.settings)];

    systemd.services."jellyfin-conf" = let
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

      brandingFile = importXML "branding" cfg.settings.branding;
      encodingFile = importXML "encoding" cfg.settings.encoding;
      metadataFile = importXML "metadata" cfg.settings.metadata;
      systemFile = importXML "system" cfg.settings.system;
    in {
      before = ["jellyfin.service"];
      requiredBy = ["jellyfin.service"];

      serviceConfig.WorkingDirectory = configDir;

      script = ''
        backupFile() {
            if [ -w "$1" ]; then
                rm -f "$1.bak"
                mv "$1" "$1.bak"
            fi
        }

        backupFile "${configDir}/branding.xml"
        cp ${brandingFile} "${configDir}/branding.xml"
        chmod 600 "${configDir}/branding.xml"

        backupFile "${configDir}/encoding.xml"
        cp ${encodingFile} "${configDir}/encoding.xml"
        chmod 600 "${configDir}/encoding.xml"

        backupFile "${configDir}/system.xml"
        cp ${systemFile} "${configDir}/system.xml"
        chmod 600 "${configDir}/system.xml"

        backupFile "${configDir}/metadata.xml"
        cp ${metadataFile} "${configDir}/metadata.xml"
        chmod 600 "${configDir}/metadata.xml"

        chown jellyfin:jellyfin -R "${configDir}"

        /run/current-system/systemd/bin/systemctl restart jellyfin.service
      '';
    };
  };
}
