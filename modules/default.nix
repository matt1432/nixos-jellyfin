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
            general = {
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

            playback.transcoding = {
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
                type = types.int;
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

      importXML = file: cfg:
        pkgs.writeTextFile {
          name = "${file}.xml";
          text = import ./templates/${file}.nix {
            inherit cfg lib mkEmptyDefault mkBool mkStringArray;
          };
        };

      brandingFile = importXML "branding" cfg.settings.general.branding;
      encodingFile = importXML "encoding" cfg.settings.playback.transcoding;
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

        chown jellyfin:jellyfin -R "${configDir}"

        /run/current-system/systemd/bin/systemctl restart jellyfin.service
      '';
    };
  };
}
