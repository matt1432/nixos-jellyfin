{
  cfg,
  mkBool,
  mkEmptyDefault,
  mkStringArray,
  ...
}:
/*
xml
*/
''
  <?xml version="1.0" encoding="utf-8"?>
  <EncodingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <EncodingThreadCount>${toString cfg.encodingThreadCount}</EncodingThreadCount>
    <TranscodingTempPath>${cfg.transcodingTempPath}</TranscodingTempPath>
    ${mkEmptyDefault cfg.fallbackFontPath "FallbackFontPath"}
    ${mkBool cfg.enableFallbackFont "EnableFallbackFont"}
    <DownMixAudioBoost>${toString cfg.downMixAudioBoost}</DownMixAudioBoost>
    <MaxMuxingQueueSize>${toString cfg.maxMuxingQueueSize}</MaxMuxingQueueSize>
    ${mkBool cfg.enableThrottling "EnableThrottling"}
    <ThrottleDelaySeconds>${toString cfg.throttleDelaySeconds}</ThrottleDelaySeconds>
    <HardwareAccelerationType>${cfg.hardwareAccelerationType}</HardwareAccelerationType>
    <EncoderAppPathDisplay>${cfg.encoderAppPathDisplay}</EncoderAppPathDisplay>
    <VaapiDevice>${cfg.vaapiDevice}</VaapiDevice>
    ${mkBool cfg.enableTonemapping "EnableTonemapping"}
    ${mkBool cfg.enableVppTonemapping "EnableVppTonemapping"}
    <TonemappingAlgorithm>${cfg.tonemappingAlgorithm}</TonemappingAlgorithm>
    <TonemappingMode>${cfg.tonemappingMode}</TonemappingMode>
    <TonemappingRange>${cfg.tonemappingRange}</TonemappingRange>
    <TonemappingDesat>${toString cfg.tonemappingDesat}</TonemappingDesat>
    <TonemappingPeak>${toString cfg.tonemappingPeak}</TonemappingPeak>
    <TonemappingParam>${toString cfg.tonemappingParam}</TonemappingParam>
    <VppTonemappingBrightness>${toString cfg.vppTonemappingBrightness}</VppTonemappingBrightness>
    <VppTonemappingContrast>${toString cfg.vppTonemappingContrast}</VppTonemappingContrast>
    <H264Crf>${toString cfg.h264Crf}</H264Crf>
    <H265Crf>${toString cfg.h265Crf}</H265Crf>
    <EncoderPreset>${cfg.encoderPreset}</EncoderPreset>
    ${mkBool cfg.deinterlaceDoubleRate "DeinterlaceDoubleRate"}
    <DeinterlaceMethod>${cfg.deinterlaceMethod}</DeinterlaceMethod>
    ${mkBool cfg.enableDecodingColorDepth10Hevc "EnableDecodingColorDepth10Hevc"}
    ${mkBool cfg.enableDecodingColorDepth10Vp9 "EnableDecodingColorDepth10Vp9"}
    ${mkBool cfg.enableEnhancedNvdecDecoder "EnableEnhancedNvdecDecoder"}
    ${mkBool cfg.preferSystemNativeHwDecoder "PreferSystemNativeHwDecoder"}
    ${mkBool cfg.enableIntelLowPowerH264HwEncoder "EnableIntelLowPowerH264HwEncoder"}
    ${mkBool cfg.enableIntelLowPowerHevcHwEncoder "EnableIntelLowPowerHevcHwEncoder"}
    ${mkBool cfg.enableHardwareEncoding "EnableHardwareEncoding"}
    ${mkBool cfg.allowHevcEncoding "AllowHevcEncoding"}
    ${mkBool cfg.enableSubtitleExtraction "EnableSubtitleExtraction"}
  ${mkStringArray cfg.hardwareDecodingCodecs "HardwareDecodingCodecs" false}
  ${mkStringArray cfg.allowOnDemandMetadataBasedKeyframeExtractionForExtensions "AllowOnDemandMetadataBasedKeyframeExtractionForExtensions" false}
  </EncodingOptions>
''
