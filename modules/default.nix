{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) boolToString concatMapStringsSep length mdDocs mkIf mkOption types;
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
            plugins = {
              pluginRepositories = mkOption {
                type = with types; listOf (submodule {
                  options = {
                    name = mkOption {
                      type = types.str;
                    };
                    url = mkOption {
                      type = types.str;
                    };
                    enable = mkOption {
                      type = types.bool;
                      default = true;
                    };
                  };
                });
                default = [
                  {
                    name = "Jellyfin Stable";
                    url = "https://repo.jellyfin.org/releases/plugin/manifest-stable.json";
                  }
                ];
              };

              removeOldPlugins = mkOption {
                type = types.bool;
                default = false;
              };
            };

            general = {
              serverName = mkOption {
                type = types.str;
                default = config.networking.hostName;
              };

              displayLanguage = mkOption {
                type = types.str;
                default = "en-US";
              };

              quickConnectAvailable = mkOption {
                type = types.bool;
                default = false;
              };

              isStartupWizardCompleted = mkOption {
                type = types.bool;
                default = false;
              };

              paths = {
                cachePath = mkOption {
                  type = types.str;
                  default = "/var/cache/jellyfin";
                };
                metadataPath = mkOption {
                  type = types.str;
                  default = "/var/lib/jellyfin/metadata";
                };
                metadataNetworkPath = mkOption {
                  type = with types; nullOr str;
                  default = null;
                };
              };

              branding = {
                loginDisclaimer = mkOption {
                  type = with types; nullOr str;
                  default = null;
                  description = mdDocs "A message that will be displayed at the bottom of the login page.";
                };

                customCss = mkOption {
                  type = types.lines;
                  default = "";
                  description = mdDocs "Apply your custom CSS code for theming/branding on the web interface.";
                };

                splashscreenEnabled = mkOption {
                  type = types.bool;
                  default = false;
                  description = mdDocs "Enable the splash screen";
                };
              };
            };

            libraries = {
              libraryMonitorDelay = mkOption {
                type = types.int;
                default = 60;
              };

              display = {
                enableFolderView = mkOption {
                  type = types.bool;
                  default = false;
                };
                enableGroupingIntoCollections = mkOption {
                  type = types.bool;
                  default = false;
                };
                displaySpecialsWithinSeasons = mkOption {
                  type = types.bool;
                  default = true;
                };
                enableExternalContentInSuggestions = mkOption {
                  type = types.bool;
                  default = true;
                };
              };

              search = {
                sortReplaceCharacters = mkOption {
                  type = with types; listOf str;
                  default = ["." "+" "%"];
                };
                sortRemoveCharacters = mkOption {
                  type = with types; listOf str;
                  default = ["," "&amp;" "-" "{" "}" "'"];
                };
                sortRemoveWords = mkOption {
                  type = with types; listOf str;
                  default = ["the" "a" "an"];
                };
              };

              metadata = {
                preferredMetadataLanguage = mkOption {
                  type = types.str;
                  default = "en";
                };
                metadataCountryCode = mkOption {
                  type = types.str;
                  default = "US";
                };
                saveMetadataHidden = mkOption {
                  type = types.bool;
                  default = false;
                };
                imageSavingConvention = mkOption {
                  type = types.str; # FIXME: enum?
                  default = "Legacy";
                };
                imageExtractionTimeoutMs = mkOption {
                  type = types.int;
                  default = 0;
                };
                libraryScanFanoutConcurrency = mkOption {
                  type = types.int;
                  default = 0;
                };
                libraryMetadataRefreshConcurrency = mkOption {
                  type = types.int;
                  default = 0;
                };
                # FIXME: are these in the right place?
                enableNormalizedItemByNameIds = mkOption {
                  type = types.bool;
                  default = true;
                };
                enableCaseSensitiveItemIds = mkOption {
                  type = types.bool;
                  default = true;
                };
                skipDeserializationForBasicTypes = mkOption {
                  type = types.bool;
                  default = true;
                };
                # FIXME: what is this?
                contentTypes = mkOption {
                  type = with types; listOf str;
                  default = [];
                };
                pathSubstitutions = mkOption {
                  type = with types; listOf str;
                  default = [];
                };
              };
            };

            playback = {
              transcoding = {
                encodingThreadCount = mkOption {
                  type = types.int;
                  default = -1;
                };
                transcodingTempPath = mkOption {
                  type = types.str;
                  default = "${jellyConfig.WorkingDirectory}/transcodes";
                };
                fallbackFontPath = mkOption {
                  type = with types; nullOr str;
                  default = null;
                };
                enableFallbackFont = mkOption {
                  type = types.bool;
                  default = false;
                };
                downMixAudioBoost = mkOption {
                  type = types.int; # FIXME: it's a float
                  default = 2;
                };
                maxMuxingQueueSize = mkOption {
                  type = types.int;
                  default = 2048;
                };
                enableThrottling = mkOption {
                  type = types.bool;
                  default = false;
                };
                throttleDelaySeconds = mkOption {
                  type = types.int;
                  default = 180;
                };
                hardwareAccelerationType = mkOption {
                  type = types.enum ["amf" "qsv" "nvenc" "v4l2m2m" "vaapi" "videotoolbox" "rkmpp"];
                  default = "vaapi";
                };
                encoderAppPathDisplay = mkOption {
                  type = types.str;
                  default = "${pkgs.jellyfin-ffmpeg}/bin/ffmpeg";
                };
                vaapiDevice = mkOption {
                  type = types.str;
                  default = "/dev/dri/renderD128";
                  description = mdDocs ''
                    The default is a DRM device that is almost guaranteed to be there on every intel platform,
                    plus it's the default one in ffmpeg if you don't specify anything
                  '';
                };
                enableTonemapping = mkOption {
                  type = types.bool;
                  default = false;
                };
                enableVppTonemapping = mkOption {
                  type = types.bool;
                  default = false;
                };
                tonemappingAlgorithm = mkOption {
                  type = types.enum ["none" "clip" "linear" "gamma" "reinhard" "hable" "mobius" "bt2390"];
                  default = "bt2390";
                };
                tonemappingMode = mkOption {
                  type = types.enum ["auto" "max" "rgb"];
                  default = "auto";
                };
                tonemappingRange = mkOption {
                  type = types.enum ["auto" "tv" "pc"];
                  default = "auto";
                };
                tonemappingDesat = mkOption {
                  type = types.int;
                  default = 0;
                };
                tonemappingPeak = mkOption {
                  type = types.int;
                  default = 100;
                };
                tonemappingParam = mkOption {
                  type = types.int;
                  default = 0;
                };
                vppTonemappingBrightness = mkOption {
                  type = types.int;
                  default = 16;
                };
                vppTonemappingContrast = mkOption {
                  type = types.int;
                  default = 1;
                };
                h264Crf = mkOption {
                  type = types.int;
                  default = 23;
                };
                h265Crf = mkOption {
                  type = types.int;
                  default = 28;
                };
                encoderPreset = mkOption {
                  type = with types; nullOr str;
                  default = null;
                };
                deinterlaceDoubleRate = mkOption {
                  type = types.bool;
                  default = false;
                };
                deinterlaceMethod = mkOption {
                  type = types.enum ["yadif" "bwdif"];
                  default = "yadif";
                };
                enableDecodingColorDepth10Hevc = mkOption {
                  type = types.bool;
                  default = true;
                };
                enableDecodingColorDepth10Vp9 = mkOption {
                  type = types.bool;
                  default = true;
                };
                enableEnhancedNvdecDecoder = mkOption {
                  type = types.bool;
                  default = true;
                  description = mdDocs "Enhanced Nvdec or system native decoder is required for DoVi to SDR tone-mapping.";
                };
                preferSystemNativeHwDecoder = mkOption {
                  type = types.bool;
                  default = true;
                };
                enableIntelLowPowerH264HwEncoder = mkOption {
                  type = types.bool;
                  default = false;
                };
                enableIntelLowPowerHevcHwEncoder = mkOption {
                  type = types.bool;
                  default = false;
                };
                enableHardwareEncoding = mkOption {
                  type = types.bool;
                  default = true;
                };
                allowHevcEncoding = mkOption {
                  type = types.bool;
                  default = true;
                };
                enableSubtitleExtraction = mkOption {
                  type = types.bool;
                  default = true;
                };
                hardwareDecodingCodecs = mkOption {
                  type = with types; listOf (enum ["h264" "hevc" "mpeg2video" "mpeg4" "vc1" "vp8" "vp9" "av1"]);
                  default = ["h264" "vc1"];
                };
                allowOnDemandMetadataBasedKeyframeExtractionForExtensions = mkOption {
                  type = with types; listOf (enum ["mkv"]);
                  default = ["mkv"];
                };
                # FIXME: what is this?
                codecsUsed = mkOption {
                  type = with types; listOf str;
                  default = [];
                };
              };

              resume = {
                minResumePct = mkOption {
                  type = types.int;
                  default = 5;
                };
                maxResumePct = mkOption {
                  type = types.int;
                  default = 90;
                };
                minResumeDurationSeconds = mkOption {
                  type = types.int;
                  default = 300;
                };
                minAudiobookResume = mkOption {
                  type = types.int;
                  default = 5;
                };
                maxAudiobookResume = mkOption {
                  type = types.int;
                  default = 5;
                };
              };

              streaming.remoteClientBitrateLimit = mkOption {
                type = types.int;
                default = 0;
              };

              tv = {
                disableLiveTvChannelUserDataName = mkOption {
                  type = types.bool;
                  default = true;
                };
              };
            };

            advanced = {
              # TODO: Some options are hidden in network.xml?
              networking = {
                isPortAuthorized = mkOption {
                  type = types.bool;
                  default = true;
                };
                corsHosts = mkOption {
                  type = with types; listOf str;
                  default = ["*"];
                };
              };

              logs = {
                logFileRetentionDays = mkOption {
                  type = types.int;
                  default = 3;
                };
                activityLogRetentionDays = mkOption {
                  type = types.int;
                  default = 30;
                };
                enableSlowResponseWarning = mkOption {
                  type = types.bool;
                  default = true;
                };
                slowResponseThresholdMs = mkOption {
                  type = types.int;
                  default = 500;
                };
                allowClientLogUpload = mkOption {
                  type = types.bool;
                  default = true;
                };
              };

              enableMetrics = mkOption {
                type = types.bool;
                default = false;
              };
            };
          };
        });
    };
  };

  config = mkIf (cfg.enable && cfg.settings != null) {
    systemd.services."jellyfin-conf" = let
      mkEmptyDefault = opt: name:
        if isNull opt
        then "<${name} />"
        else "<${name}>${opt}</${name}>";

      mkBool = opt: name: "<${name}>${boolToString opt}</${name}>";

      mkStringArray = opt: name:
        if length == 0
        then "<${name} />"
        else ''
          <${name}>
          ${concatMapStringsSep "\n" (x: "    <string>${x}</string>") opt}
            </${name}>
        '';

      indent = "  ";

      mkPluginRepoInfo = repo: ''
        ${indent}<RepositoryInfo>
        ${indent}${indent}<Name>${repo.name}</Name>
        ${indent}${indent}<Url>${repo.url}</Url>
        ${indent}${indent}<Enabled>${boolToString repo.enable}</Enabled>
        ${indent}</RepositoryInfo>
      '';

      importXML = file: cfg:
        pkgs.writeTextFile {
          name = "${file}.xml";
          text = import ./templates/${file}.nix {
            inherit cfg lib mkEmptyDefault mkBool mkStringArray mkPluginRepoInfo;
          };
        };

      brandingFile = importXML "branding" cfg.settings.general.branding;
      encodingFile = importXML "encoding" cfg.settings.playback.transcoding;
      systemFile = importXML "system" cfg.settings;
    in {
      wantedBy = ["multi-user.target"];
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

        chown jellyfin:jellyfin -R "${configDir}"

        /run/current-system/systemd/bin/systemctl restart jellyfin.service
      '';
    };
  };
}
