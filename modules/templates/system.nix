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
    <LogFileRetentionDays>${toString cfg.logFileRetentionDays}</LogFileRetentionDays>
    ${mkBool cfg.isStartupWizardCompleted "IsStartupWizardCompleted"}
    <CachePath>${cfg.cachePath}</CachePath>
    ${mkBool cfg.enableMetrics "EnableMetrics"}
    ${mkBool cfg.enableNormalizedItemByNameIds "EnableNormalizedItemByNameIds"}
    ${mkBool cfg.isPortAuthorized "IsPortAuthorized"}
    ${mkBool cfg.quickConnectAvailable "QuickConnectAvailable"}
    ${mkBool cfg.enableCaseSensitiveItemIds "EnableCaseSensitiveItemIds"}
    ${mkBool cfg.disableLiveTvChannelUserDataName "DisableLiveTvChannelUserDataName"}
    <MetadataPath>${cfg.metadataPath}</MetadataPath>
    ${mkEmptyDefault cfg.metadataNetworkPath "MetadataNetworkPath"}
    <PreferredMetadataLanguage>${cfg.preferredMetadataLanguage}</PreferredMetadataLanguage>
    <MetadataCountryCode>${cfg.metadataCountryCode}</MetadataCountryCode>
  ${mkStringArray cfg.sortReplaceCharacters "SortReplaceCharacters" false}
  ${mkStringArray cfg.sortRemoveCharacters "SortRemoveCharacters" false}
  ${mkStringArray cfg.sortRemoveWords "SortRemoveWords" false}
    <MinResumePct>${toString cfg.minResumePct}</MinResumePct>
    <MaxResumePct>${toString cfg.maxResumePct}</MaxResumePct>
    <MinResumeDurationSeconds>${toString cfg.minResumeDurationSeconds}</MinResumeDurationSeconds>
    <MinAudiobookResume>${toString cfg.minAudiobookResume}</MinAudiobookResume>
    <MaxAudiobookResume>${toString cfg.maxAudiobookResume}</MaxAudiobookResume>
    <LibraryMonitorDelay>${toString cfg.libraryMonitorDelay}</LibraryMonitorDelay>
    <ImageSavingConvention>${cfg.imageSavingConvention}</ImageSavingConvention>
    <MetadataOptions>
  ${lib.concatMapStringsSep "\n" mkMetadataOptions cfg.metadataOptions}
    </MetadataOptions>
    ${mkBool cfg.skipDeserializationForBasicTypes "SkipDeserializationForBasicTypes"}
    <ServerName>${cfg.serverName}</ServerName>
    <UICulture>${cfg.displayLanguage}</UICulture>
    ${mkBool cfg.saveMetadataHidden "SaveMetadataHidden"}
  ${mkStringArray cfg.contentTypes "ContentTypes" false}
    <RemoteClientBitrateLimit>${toString cfg.remoteClientBitrateLimit}</RemoteClientBitrateLimit>
    ${mkBool cfg.enableFolderView "EnableFolderView"}
    ${mkBool cfg.enableGroupingIntoCollections "EnableGroupingIntoCollections"}
    ${mkBool cfg.displaySpecialsWithinSeasons "DisplaySpecialsWithinSeasons"}
  ${mkStringArray cfg.codecsUsed "CodecsUsed" false}
    <PluginRepositories>
  ${lib.concatMapStringsSep "\n" mkPluginRepoInfo cfg.pluginRepositories}
    </PluginRepositories>
    ${mkBool cfg.enableExternalContentInSuggestions "EnableExternalContentInSuggestions"}
    <ImageExtractionTimeoutMs>${toString cfg.imageExtractionTimeoutMs}</ImageExtractionTimeoutMs>
  ${mkStringArray cfg.pathSubstitutions "PathSubstitutions" false}
    ${mkBool cfg.enableSlowResponseWarning "EnableSlowResponseWarning"}
    <SlowResponseThresholdMs>${toString cfg.slowResponseThresholdMs}</SlowResponseThresholdMs>
  ${mkStringArray cfg.corsHosts "CorsHosts" false}
    <ActivityLogRetentionDays>${toString cfg.activityLogRetentionDays}</ActivityLogRetentionDays>
    <LibraryScanFanoutConcurrency>${toString cfg.libraryScanFanoutConcurrency}</LibraryScanFanoutConcurrency>
    <LibraryMetadataRefreshConcurrency>${toString cfg.libraryMetadataRefreshConcurrency}</LibraryMetadataRefreshConcurrency>
    ${mkBool cfg.removeOldPlugins "RemoveOldPlugins"}
    ${mkBool cfg.allowClientLogUpload "AllowClientLogUpload"}
  </ServerConfiguration>
''
