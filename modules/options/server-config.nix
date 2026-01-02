# Gets all the options from this file:
# https://github.com/jellyfin/jellyfin/blob/master/MediaBrowser.Model/Configuration/ServerConfiguration.cs
#
# They go into 'system.xml'
#
{
  config,
  lib,
  jellyConfig,
  ...
}: let
  inherit (lib) mdDocs mkOption types;
in {
  enableMetrics = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether to enable prometheus metrics exporting.
    '';
  };

  enableNormalizedItemByNameIds = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs '''';
  };

  isPortAuthorized = mkOption {
    type = types.bool;
    default = true; # FIXME: is this really the default?
    description = mdDocs ''
      Value indicating whether this instance is port authorized.
    '';
  };

  quickConnectAvailable = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs ''
      Value indicating whether quick connect is available for use on this server.
    '';
  };

  enableCaseSensitiveItemIds = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs '''';
  };

  disableLiveTvChannelUserDataName = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs '''';
  };

  metadataPath = mkOption {
    type = types.str;
    default = "${jellyConfig.dataDir}/metadata";
    description = mdDocs ''
      The metadata path.
    '';
  };

  metadataNetworkPath = mkOption {
    type = with types; nullOr str;
    default = null;
    description = mdDocs '''';
  };

  preferredMetadataLanguage = mkOption {
    type = types.str;
    default = "en";
    description = mdDocs ''
      The preferred metadata language.
    '';
  };

  metadataCountryCode = mkOption {
    type = types.str;
    default = "US";
    description = mdDocs ''
      The metadata country code.
    '';
  };

  sortReplaceCharacters = mkOption {
    type = with types; listOf str;
    default = ["." "+" "%"];
    description = mdDocs ''
      Characters to be replaced with a ' ' in strings to create a sort name.
    '';
  };

  sortRemoveCharacters = mkOption {
    type = with types; listOf str;
    default = ["," "&amp;" "-" "{" "}" "'"];
    description = mdDocs ''
      Characters to be removed from strings to create a sort name.
    '';
  };

  sortRemoveWords = mkOption {
    type = with types; listOf str;
    default = ["the" "a" "an"];
    description = mdDocs ''
      Words to be removed from strings to create a sort name.
    '';
  };

  minResumePct = mkOption {
    type = types.int;
    default = 5;
    description = mdDocs ''
      The minimum percentage of an item that must be played in order for playstate to be updated.
    '';
  };

  maxResumePct = mkOption {
    type = types.int;
    default = 90;
    description = mdDocs ''
      The maximum percentage of an item that can be played while still saving playstate. If this percentage is crossed playstate will be reset to the beginning and the item will be marked watched.
    '';
  };

  minResumeDurationSeconds = mkOption {
    type = types.int;
    default = 300;
    description = mdDocs ''
      The minimum duration that an item must have in order to be eligible for playstate updates..
    '';
  };

  minAudiobookResume = mkOption {
    type = types.int;
    default = 5;
    description = mdDocs ''
      The minimum minutes of a book that must be played in order for playstate to be updated.
    '';
  };
  maxAudiobookResume = mkOption {
    type = types.int;
    default = 5;
    description = mdDocs ''
      The remaining minutes of a book that can be played while still saving playstate. If this percentage is crossed playstate will be reset to the beginning and the item will be marked watched.
    '';
  };

  # TODO: add to system.nix
  inactiveSessionThreshold = mkOption {
    type = types.int;
    default = 10;
    description = mdDocs ''
      The threshold in minutes after a inactive session gets closed automatically.!
      If set to 0 the check for inactive sessions gets disabled.
    '';
  };

  libraryMonitorDelay = mkOption {
    type = types.int;
    default = 60;
    description = mdDocs ''
      The delay in seconds that we will wait after a file system change to try and discover what has been added/removed\
      Some delay is necessary with some items because their creation is not atomic.  It involves the creation of several different directories and files.
    '';
  };

  # TODO: add to system.nix
  libraryUpdateDuration = mkOption {
    type = types.int;
    default = 30;
    description = mdDocs ''
      The duration in seconds that we will wait after a library updated event before executing the library changed notification.
    '';
  };

  imageSavingConvention = mkOption {
    type = types.enum ["Legacy" "Compatible"];
    default = "Legacy";
    description = mdDocs ''
      The image saving convention.
    '';
  };

  metadataOptions = mkOption {
    description = mdDocs '''';
    type = with types;
      listOf (submodule {
        options = {
          itemType = mkOption {
            type = enum [
              "Book"
              "Movie"
              "MusicVideo"
              "Series"
              "MusicAlbum"
              "MusicArtist"
              "BoxSet"
              "Season"
              "Episode"
            ];
          };
          disabledMetadataSavers = mkOption {
            type = nullOr (listOf str);
            default = null;
          };
          localMetadataReaderOrder = mkOption {
            type = nullOr (listOf str);
            default = null;
          };
          disabledMetadataFetchers = mkOption {
            type = nullOr (listOf str);
            default = null;
          };
          metadataFetcherOrder = mkOption {
            type = nullOr (listOf str);
            default = null;
          };
          disabledImageFetchers = mkOption {
            type = nullOr (listOf str);
            default = null;
          };
          imageFetcherOrder = mkOption {
            type = nullOr (listOf str);
            default = null;
          };
        };
      });
    default = [
      {itemType = "Book";}
      {itemType = "Movie";}
      {
        itemType = "MusicVideo";
        disabledMetadataFetchers = ["The Open Movie Database"];
        disabledImageFetchers = ["The Open Movie Database"];
      }
      {itemType = "Series";}
      {
        itemType = "MusicAlbum";
        disabledMetadataFetchers = ["TheAudioDB"];
      }
      {
        itemType = "MusicArtist";
        disabledMetadataFetchers = ["TheAudioDB"];
      }
      {itemType = "BoxSet";}
      {itemType = "Season";}
      {itemType = "Episode";}
    ];
  };

  skipDeserializationForBasicTypes = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs '''';
  };

  serverName = mkOption {
    type = types.str;
    default = config.networking.hostName;
    description = mdDocs '''';
  };

  # XML name is UICulture
  displayLanguage = mkOption {
    type = types.str;
    default = "en-US";
    description = mdDocs '''';
  };

  saveMetadataHidden = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs '''';
  };

  # FIXME: what is this?
  # public NameValuePair[] ContentTypes { get; set; } = Array.Empty<NameValuePair>();
  contentTypes = mkOption {
    type = with types; nullOr (listOf str);
    default = null;
    description = mdDocs '''';
  };

  remoteClientBitrateLimit = mkOption {
    type = types.int;
    default = 0;
    description = mdDocs '''';
  };

  enableFolderView = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs '''';
  };

  enableGroupingMoviesIntoCollections = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs '''';
  };

  enableGroupingShowsIntoCollections = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs '''';
  };

  displaySpecialsWithinSeasons = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs '''';
  };

  # FIXME: what is this?
  # public string[] CodecsUsed { get; set; } = Array.Empty<string>();
  codecsUsed = mkOption {
    type = with types; nullOr (listOf str);
    default = null;
    description = mdDocs '''';
  };

  pluginRepositories = mkOption {
    description = mdDocs '''';
    type = with types;
      listOf (submodule {
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

  enableExternalContentInSuggestions = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs '''';
  };

  imageExtractionTimeoutMs = mkOption {
    type = types.int;
    default = 0;
    description = mdDocs '''';
  };

  # FIXME: what is this?
  # public PathSubstitution[] PathSubstitutions { get; set; } = Array.Empty<PathSubstitution>();
  pathSubstitutions = mkOption {
    type = with types; nullOr (listOf str);
    default = null;
    description = mdDocs '''';
  };

  enableSlowResponseWarning = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs ''
      Value indicating whether slow server responses should be logged as a warning.
    '';
  };

  slowResponseThresholdMs = mkOption {
    type = types.int;
    default = 500;
    description = mdDocs ''
      The threshold for the slow response time warning in ms.
    '';
  };

  corsHosts = mkOption {
    type = with types; listOf str;
    default = ["*"];
    description = mdDocs ''
      The cors hosts.
    '';
  };

  activityLogRetentionDays = mkOption {
    type = types.int;
    default = 30;
    description = mdDocs ''
      The number of days we should retain activity logs.
    '';
  };

  libraryScanFanoutConcurrency = mkOption {
    type = types.int;
    default = 0;
    description = mdDocs ''
      How the library scan fans out.
    '';
  };

  libraryMetadataRefreshConcurrency = mkOption {
    type = types.int;
    default = 0;
    description = ''
      How many metadata refreshes can run concurrently.
    '';
  };

  removeOldPlugins = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether older plugins should automatically be deleted from the plugin folder.
    '';
  };

  allowClientLogUpload = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs ''
      Value indicating whether clients should be allowed to upload logs.
    '';
  };

  # TODO: add all the following to system.nix
  dummyChapterDuration = mkOption {
    type = types.int;
    default = 0;
    description = mdDocs ''
      The dummy chapter duration in seconds, use 0 (zero) or less to disable generation alltogether.
    '';
  };

  chapterImageResolution = mkOption {
    type = types.enum ["matchsource" "p144" "p240" "p360" "p480" "p720" "p1080" "p1440" "p2160"];
    default = "matchsource";
    description = mdDocs ''
      The chapter image resolution.
    '';
  };

  parallelImageEncodingLimit = mkOption {
    type = types.int;
    default = 0;
    description = mdDocs ''
      The limit for parallel image encoding.
    '';
  };

  # FIXME: in what file does this go to?
  castReceiverApplications = mkOption {
    default = null;
    type = with types;
      nullOr (listOf (submodule {
        options = {
          id = mkOption {
            type = str;
            description = mdDocs ''
              The cast receiver application id.
            '';
          };
          name = mkOption {
            type = str;
            description = mdDocs ''
              The cast receiver application name.
            '';
          };
        };
      }));
  };

  # trickplayOptions: https://github.com/jellyfin/jellyfin/blob/407cf5d0bf9d3563ae77fd34ce29ffae5af4339f/MediaBrowser.Model/Configuration/TrickplayOptions.cs#L9
}
