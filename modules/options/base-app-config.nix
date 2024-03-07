# Gets all the options from this file:
# https://github.com/jellyfin/jellyfin/blob/master/MediaBrowser.Model/Configuration/BaseApplicationConfiguration.cs
#
# They go into 'system.xml'
#
{lib, ...}: let
  inherit (lib) mdDocs mkOption types;
in {
  isStartupWizardCompleted = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      true if this instance is first run.
      otherwise, false
    '';
  };

  cachePath = mkOption {
    type = types.str;
    default = "/var/cache/jellyfin";
    description = mdDocs ''
      The cache path.
    '';
  };

  logFileRetentionDays = mkOption {
    type = types.int;
    default = 3;
    description = mdDocs ''
      The log file retention days.
    '';
  };
}
