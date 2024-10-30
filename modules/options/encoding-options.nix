# Gets all the options from this file:
# https://github.com/jellyfin/jellyfin/blob/master/MediaBrowser.Model/Configuration/EncodingOptions.cs
#
# They go into 'encoding.xml'
#
{
  cfg,
  lib,
  jellyConfig,
  ffmpeg,
  ...
}: let
  inherit (lib) mdDocs mkOption types;
in {
  encodingThreadCount = mkOption {
    type = types.int;
    default = -1;
    description = mdDocs ''
      The thread count used for encoding.\
      -1 is auto\
      0 is max
    '';
  };

  transcodingTempPath = mkOption {
    type = types.str;
    default = "${jellyConfig.dataDir}/transcodes";
    description = mdDocs ''
      The temporary transcoding path.
    '';
  };

  fallbackFontPath = mkOption {
    type = with types; nullOr str;
    default = null;
    description = mdDocs ''
      The path to the fallback font.
    '';
  };

  enableFallbackFont = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether to use the fallback font.
    '';
  };

  # TODO: add to encoding.nix
  enableAudioVbr = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether audio VBR is enabled.
    '';
  };

  downMixAudioBoost = mkOption {
    type = types.number;
    default = 2;
    description = mdDocs ''
      The audio boost applied when downmixing audio.
    '';
  };

  downMixStereoAlgorithm = mkOption {
    type = types.enum ["none" "dave750" "nightmodedialogue"];
    default = "none";
    description = mdDocs ''
      The algorithm used for downmixing audio to stereo.
    '';
  };

  maxMuxingQueueSize = mkOption {
    type = types.int;
    default = 2048;
    description = mdDocs ''
      The maximum size of the muxing queue.
    '';
  };

  enableThrottling = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether throttling is enabled.
    '';
  };

  throttleDelaySeconds = mkOption {
    type = types.int;
    default = 180;
    description = mdDocs ''
      The delay after which throttling happens.
    '';
  };

  # TODO: add to encoding.nix
  enableSegmentDeletion = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether segment deletion is enabled.
    '';
  };

  # TODO: add to encoding.nix
  segmentKeepSeconds = mkOption {
    type = types.int;
    default = 720;
    description = mdDocs ''
      Seconds for which segments should be kept before being deleted.
    '';
  };

  hardwareAccelerationType = mkOption {
    type = types.enum ["amf" "qsv" "nvenc" "v4l2m2m" "vaapi" "videotoolbox" "rkmpp"];
    default = "vaapi";
    description = mdDocs ''
      The hardware acceleration type.
    '';
  };

  # TODO: add to encoding.nix
  encoderAppPath = mkOption {
    type = types.str;
    default = "${ffmpeg}/bin/ffmpeg";
    description = mdDocs ''
      The current FFmpeg path being used by the system.
    '';
  };

  encoderAppPathDisplay = mkOption {
    type = types.str;
    default = cfg.encoderAppPath;
    readOnly = true;
    description = mdDocs ''
      The current FFmpeg path displayed on the transcode page.
    '';
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
    description = mdDocs ''
      Value indicating whether tonemapping is enabled.
    '';
  };

  enableVppTonemapping = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether VPP tonemapping is enabled.
    '';
  };

  tonemappingAlgorithm = mkOption {
    type = types.enum ["none" "clip" "linear" "gamma" "reinhard" "hable" "mobius" "bt2390"];
    default = "bt2390";
    description = mdDocs ''
      The tone-mapping algorithm.
    '';
  };

  tonemappingMode = mkOption {
    type = types.enum ["auto" "max" "rgb"];
    default = "auto";
    description = mdDocs ''
      The tone-mapping mode.
    '';
  };

  tonemappingRange = mkOption {
    type = types.enum ["auto" "tv" "pc"];
    default = "auto";
    description = mdDocs ''
      The tone-mapping range.
    '';
  };

  tonemappingDesat = mkOption {
    type = types.number;
    default = 0;
    description = mdDocs ''
      The tone-mapping desaturation.
    '';
  };

  tonemappingPeak = mkOption {
    type = types.number;
    default = 100;
    description = mdDocs ''
      The tone-mapping peak.
    '';
  };

  tonemappingParam = mkOption {
    type = types.number;
    default = 0;
    description = mdDocs ''
      The tone-mapping parameters.
    '';
  };

  vppTonemappingBrightness = mkOption {
    type = types.number;
    default = 16;
    description = mdDocs ''
      The VPP tone-mapping brightness.
    '';
  };

  vppTonemappingContrast = mkOption {
    type = types.number;
    default = 1;
    description = mdDocs ''
      The VPP tone-mapping contrast.
    '';
  };

  h264Crf = mkOption {
    type = types.int;
    default = 23;
    description = mdDocs ''
      The H264 CRF.
    '';
  };

  h265Crf = mkOption {
    type = types.int;
    default = 28;
    description = mdDocs ''
      The H265 CRF.
    '';
  };

  encoderPreset = mkOption {
    type = with types; nullOr str;
    default = null;
    description = mdDocs ''
      The encoder preset.
    '';
  };

  deinterlaceDoubleRate = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether the framerate is doubled when deinterlacing.
    '';
  };

  deinterlaceMethod = mkOption {
    type = types.enum ["yadif" "bwdif"];
    default = "yadif";
    description = mdDocs ''
      The deinterlace method.
    '';
  };

  enableDecodingColorDepth10Hevc = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs ''
      Value indicating whether 10bit HEVC decoding is enabled.
    '';
  };

  enableDecodingColorDepth10Vp9 = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs ''
      Value indicating whether 10bit VP9 decoding is enabled.
    '';
  };

  enableEnhancedNvdecDecoder = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs ''
      Value indicating whether the enhanced NVDEC is enabled.\
      Enhanced Nvdec or system native decoder is required for DoVi to SDR tone-mapping.
    '';
  };

  preferSystemNativeHwDecoder = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs ''
      Value indicating whether the system native hardware decoder should be used.
    '';
  };

  enableIntelLowPowerH264HwEncoder = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether the Intel H264 low-power hardware encoder should be used.
    '';
  };

  enableIntelLowPowerHevcHwEncoder = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether the Intel HEVC low-power hardware encoder should be used.
    '';
  };

  enableHardwareEncoding = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs ''
      Value indicating whether hardware encoding is enabled.
    '';
  };

  allowHevcEncoding = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether HEVC encoding is enabled.
    '';
  };

  # TODO: add to encoding.nix
  allowAv1Encoding = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether AV1 encoding is enabled.
    '';
  };

  # TODO: add to encoding.nix
  allowMjpegEncoding = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether MJPEG encoding is enabled.
    '';
  };

  enableSubtitleExtraction = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs ''
      Value indicating whether subtitle extraction is enabled.
    '';
  };

  hardwareDecodingCodecs = mkOption {
    type = with types; listOf (enum ["h264" "hevc" "mpeg2video" "mpeg4" "vc1" "vp8" "vp9" "av1"]);
    default = ["h264" "vc1"];
    description = mdDocs ''
      The codecs hardware encoding is used for.
    '';
  };

  allowOnDemandMetadataBasedKeyframeExtractionForExtensions = mkOption {
    type = with types; listOf (enum ["mkv"]);
    default = ["mkv"];
    description = mdDocs ''
      The file extensions on-demand metadata based keyframe extraction is enabled for.
    '';
  };
}
