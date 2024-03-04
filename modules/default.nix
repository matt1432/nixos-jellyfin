{
  config,
  lib,
  ...
}: let
  inherit (lib) mdDocs mkIf mkOption types;
  inherit (builtins) toFile;

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

  config = mkIf (cfg.enable && cfg.settings != null) {
    systemd.services."jellyfin-conf" = let
      jellyConfig = config.systemd.services.jellyfin.serviceConfig;
      configDir = "${jellyConfig.WorkingDirectory}/config";

      brandingFile = toFile "branding.xml" (import ./templates/branding.nix {inherit cfg;});
    in {
      wantedBy = ["multi-user.target"];
      before = ["jellyfin.service"];
      requiredBy = ["jellyfin.service"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = configDir;
      };

      script = ''
        backupFile() {
            if [ -h "$1" ]; then
                rm "$1"
            else
                rm -f "$1.bak"
                mv "$1" "$1.bak"
            fi
        }

        backupFile "./branding.xml"
        ln -sf ${brandingFile} "$1" ./branding.xml
      '';
    };
  };
}
