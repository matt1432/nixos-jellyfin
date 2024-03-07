# Gets all the options from this file:
# https://github.com/jellyfin/jellyfin/blob/master/MediaBrowser.Model/Configuration/MetadataConfiguration.cs
#
# They go into 'metadata.xml'
#
{lib, ...}: let
  inherit (lib) mdDocs mkOption types;
in {
  useFileCreationTimeForDateAdded = mkOption {
    type = types.bool;
    default = true;
    description = mdDocs ''
      If a metadata value is present, it will always be used before either of the options.
    '';
  };
}
