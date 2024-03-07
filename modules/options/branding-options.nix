# Gets all the options from this file:
# https://github.com/jellyfin/jellyfin/blob/master/MediaBrowser.Model/Branding/BrandingOptions.cs
#
# They go into 'branding.xml'
#
{lib, ...}: let
  inherit (lib) mdDocs mkOption types;
in {
  loginDisclaimer = mkOption {
    type = with types; nullOr str;
    default = null;
    description = mdDocs ''
      The login disclaimer.
    '';
  };

  customCss = mkOption {
    type = with types; nullOr lines;
    default = null;
    description = mdDocs ''
      The custom CSS.
    '';
  };

  splashscreenEnabled = mkOption {
    type = types.bool;
    default = false;
    description = mdDocs ''
      Value indicating whether to enable the splashscreen.
    '';
  };
}
