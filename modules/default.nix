{
  config,
  lib,
  ...
}: let
  inherit (lib) mdDocs mkIf mkOption types;

  cfg = config.services.jellyfin;
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
                  type = types.str;
                  default = " ";
                  description = mdDocs "A message that will be displayed at the bottom of the login page.";
                };

                customCss = mkOption {
                  type = types.lines;
                  default = " ";
                  description = mdDocs "Apply your custom CSS code for theming/branding on the web interface.";
                };

                splashscreenEnabled = mkOption {
                  type = types.bool;
                  default = false;
                  description = mdDocs "Enable the splash screen";
                };
              };
            };
          };
        });
    };
  };

  config = mkIf (cfg.enable && cfg.settings != null) {};
}
