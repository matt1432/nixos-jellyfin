self: {
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
    getExe
    head
    literalExpression
    mkEnableOption
    mkForce
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    optionalString
    splitString
    types
    ;

  inherit (builtins) functionArgs;

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

  configSetupCmds = concatMapStringsSep "\n" (x: mkConfigSetup x.file x.name) [
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
  ];
in {
  options.services.jellyfin = {
    webPackage = mkOption {
      type = types.package;
      default = pkgs.jellyfin-web;
      defaultText = literalExpression "pkgs.jellyfin-web";
      example = literalExpression ''
        pkgs.jellyfin-web.override {
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
      default = pkgs.jellyfin-ffmpeg;
      defaultText = literalExpression "nixos-jellyfin.packages.x86_64-linux.jellyfin-ffmpeg";
      description = ''
        The jellyfin-ffmpeg package to use.\
        By default, this option will use the `packages.jellyfin-ffmpeg` as exposed by this flake.
      '';
    };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      default = let
        pkgFile = head (splitString [":"] cfg.package.meta.position);
        args = functionArgs (import pkgFile);
      in
        cfg.package.override ({
            jellyfin-ffmpeg = cfg.ffmpegPackage;
          }
          // optionalAttrs (args ? "jellyfin-web") {jellyfin-web = cfg.webPackage;});
      defaultText = literalExpression ''
        pkgs.jellyfin.override {
          jellyfin-ffmpeg = pkgs.jellyfin-ffmpeg;
        }
      '';
      description = ''
        The package defined by `services.jellyfin.package` with overrides applied.
      '';
    };

    waitForReady = {
      enable = mkEnableOption ''
        waiting for Jellyfin's health endpoint to report `Healthy` before
        `jellyfin.service` is considered started. This makes `After=jellyfin.service`
        in other units mean that the Jellyfin API is actually reachable
      '';

      url = mkOption {
        type = types.str;
        default = "http://127.0.0.1:8096/health";
        description = ''
          The URL polled until it returns `Healthy`.
        '';
      };

      timeout = mkOption {
        type = types.str;
        default = "5min";
        description = ''
          Value of `TimeoutStartSec` for `jellyfin.service`. This covers both
          Jellyfin's startup and the time spent waiting for it to be healthy.
        '';
      };
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

  config = mkIf cfg.enable {
    nixpkgs.overlays = [self.overlays.default];

    systemd.services."jellyfin" = mkMerge [
      {
        serviceConfig.ExecStart = mkForce (concatStringsSep " " [
          "${cfg.finalPackage}/bin/jellyfin"
          "--datadir '${cfg.dataDir}'"
          "--configdir '${cfg.configDir}'"
          "--cachedir '${cfg.cacheDir}'"
          "--logdir '${cfg.logDir}'"
        ]);
      }

      (mkIf (cfg.settings != null) {
        restartTriggers = [(builtins.toJSON cfg.settings)];

        preStart = ''
          backupFile() {
              if [ -w "$1" ]; then
                  rm -f "$1.bak"
                  mv "$1" "$1.bak"
              fi
          }

          ${configSetupCmds}
        '';
      })

      (mkIf cfg.waitForReady.enable {
        # systemd only considers the unit started once ExecStartPost has exited,
        # so units ordered after jellyfin.service wait for this loop.
        postStart = ''
          until [ "$(${getExe pkgs.curl} -fsS '${cfg.waitForReady.url}' 2>/dev/null)" = "Healthy" ]; do
            sleep 2
          done
        '';

        serviceConfig.TimeoutStartSec = cfg.waitForReady.timeout;
      })
    ];
  };

  # For accurate stack trace
  _file = ./default.nix;
}
