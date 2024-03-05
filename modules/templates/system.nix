{
  cfg,
  lib,
  mkBool,
  mkEmptyDefault,
  mkMetadataOptions,
  mkStringArray,
  mkPluginRepoInfo,
  ...
}:
/*
xml
*/
''
  <?xml version="1.0" encoding="utf-8"?>
  <ServerConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <LogFileRetentionDays>${toString cfg.advanced.logs.logFileRetentionDays}</LogFileRetentionDays>
    ${mkBool cfg.general.isStartupWizardCompleted "IsStartupWizardCompleted"}
    <CachePath>${cfg.general.paths.cachePath}</CachePath>
    ${mkBool cfg.advanced.enableMetrics "EnableMetrics"}
    ${mkBool cfg.libraries.metadata.enableNormalizedItemByNameIds "EnableNormalizedItemByNameIds"}
    ${mkBool cfg.advanced.networking.isPortAuthorized "IsPortAuthorized"}
    ${mkBool cfg.general.quickConnectAvailable "QuickConnectAvailable"}
    ${mkBool cfg.libraries.metadata.enableCaseSensitiveItemIds "EnableCaseSensitiveItemIds"}
    ${mkBool cfg.playback.tv.disableLiveTvChannelUserDataName "DisableLiveTvChannelUserDataName"}
    <MetadataPath>${cfg.general.paths.metadataPath}</MetadataPath>
    ${mkEmptyDefault cfg.general.paths.metadataNetworkPath "MetadataNetworkPath"}
    <PreferredMetadataLanguage>${cfg.libraries.metadata.preferredMetadataLanguage}</PreferredMetadataLanguage>
    <MetadataCountryCode>${cfg.libraries.metadata.metadataCountryCode}</MetadataCountryCode>
  ${mkStringArray cfg.libraries.search.sortReplaceCharacters "SortReplaceCharacters" false}
  ${mkStringArray cfg.libraries.search.sortRemoveCharacters "SortRemoveCharacters" false}
  ${mkStringArray cfg.libraries.search.sortRemoveWords "SortRemoveWords" false}
    <MinResumePct>${toString cfg.playback.resume.minResumePct}</MinResumePct>
    <MaxResumePct>${toString cfg.playback.resume.maxResumePct}</MaxResumePct>
    <MinResumeDurationSeconds>${toString cfg.playback.resume.minResumeDurationSeconds}</MinResumeDurationSeconds>
    <MinAudiobookResume>${toString cfg.playback.resume.minAudiobookResume}</MinAudiobookResume>
    <MaxAudiobookResume>${toString cfg.playback.resume.maxAudiobookResume}</MaxAudiobookResume>
    <LibraryMonitorDelay>${toString cfg.libraries.libraryMonitorDelay}</LibraryMonitorDelay>
    <ImageSavingConvention>${cfg.libraries.metadata.imageSavingConvention}</ImageSavingConvention>
    <MetadataOptions>
  ${lib.concatMapStringsSep "\n" mkMetadataOptions cfg.libraries.metadata.metadataOptions}
    </MetadataOptions>
    ${mkBool cfg.libraries.metadata.skipDeserializationForBasicTypes "SkipDeserializationForBasicTypes"}
    <ServerName>${cfg.general.serverName}</ServerName>
    <UICulture>${cfg.general.displayLanguage}</UICulture>
    ${mkBool cfg.libraries.metadata.saveMetadataHidden "SaveMetadataHidden"}
  ${mkStringArray cfg.libraries.metadata.contentTypes "ContentTypes" false}
    <RemoteClientBitrateLimit>${toString cfg.playback.streaming.remoteClientBitrateLimit}</RemoteClientBitrateLimit>
    ${mkBool cfg.libraries.display.enableFolderView "EnableFolderView"}
    ${mkBool cfg.libraries.display.enableGroupingIntoCollections "EnableGroupingIntoCollections"}
    ${mkBool cfg.libraries.display.displaySpecialsWithinSeasons "DisplaySpecialsWithinSeasons"}
  ${mkStringArray cfg.playback.transcoding.codecsUsed "CodecsUsed" false}
    <PluginRepositories>
  ${lib.concatMapStringsSep "\n" mkPluginRepoInfo cfg.plugins.pluginRepositories}
    </PluginRepositories>
    ${mkBool cfg.libraries.display.enableExternalContentInSuggestions "EnableExternalContentInSuggestions"}
    <ImageExtractionTimeoutMs>${toString cfg.libraries.metadata.imageExtractionTimeoutMs}</ImageExtractionTimeoutMs>
  ${mkStringArray cfg.libraries.metadata.pathSubstitutions "PathSubstitutions" false}
    ${mkBool cfg.advanced.logs.enableSlowResponseWarning "EnableSlowResponseWarning"}
    <SlowResponseThresholdMs>${toString cfg.advanced.logs.slowResponseThresholdMs}</SlowResponseThresholdMs>
  ${mkStringArray cfg.advanced.networking.corsHosts "CorsHosts" false}
    <ActivityLogRetentionDays>${toString cfg.advanced.logs.activityLogRetentionDays}</ActivityLogRetentionDays>
    <LibraryScanFanoutConcurrency>${toString cfg.libraries.metadata.libraryScanFanoutConcurrency}</LibraryScanFanoutConcurrency>
    <LibraryMetadataRefreshConcurrency>${toString cfg.libraries.metadata.libraryMetadataRefreshConcurrency}</LibraryMetadataRefreshConcurrency>
    ${mkBool cfg.plugins.removeOldPlugins "RemoveOldPlugins"}
    ${mkBool cfg.advanced.logs.allowClientLogUpload "AllowClientLogUpload"}
  </ServerConfiguration>
''
