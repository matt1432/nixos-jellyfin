{
  inputs = {
    nixpkgs = {
      type = "git";
      url = "https://github.com/NixOS/nixpkgs";
      ref = "nixos-unstable";
      shallow = true;
    };

    systems = {
      type = "github";
      owner = "nix-systems";
      repo = "default-linux";
    };
  };

  outputs = {
    self,
    systems,
    nixpkgs,
    ...
  }: let
    perSystem = attrs:
      nixpkgs.lib.genAttrs (import systems) (system:
        attrs (import nixpkgs {inherit system;}));

    perSystemWithCUDA = attrs:
      nixpkgs.lib.genAttrs (import systems) (system:
        attrs
        (import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        })
        (import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        }));
  in {
    overlays = {
      jellyfin = import ./pkgs;
      default = self.overlays.jellyfin;
    };

    packages = perSystemWithCUDA (pkgs: cudaPkgs: {
      inherit (pkgs) jellyfin jellyfin-web jellyfin-ffmpeg jellyfin-media-player;
      inherit (cudaPkgs) jellyfin-ffmpeg-cuda;
    });

    nixosModules = {
      jellyfin = import ./modules self;
      default = self.nixosModules.jellyfin;
    };

    formatter = perSystem (pkgs: pkgs.alejandra);

    devShells = perSystem (pkgs: {
      update = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          bash
          git
          nix-update
        ];
      };

      build = pkgs.mkShell {
        packages = with pkgs; [
          bash
          git

          (writeShellApplication {
            name = "buildAll";

            text = ''
              nix build .#jellyfin --print-build-logs
              nix build .#jellyfin-web --print-build-logs
              nix build .#jellyfin-media-player --print-build-logs
              nix build .#jellyfin-ffmpeg --print-build-logs
            '';
          })
        ];
      };
    });
  };
}
