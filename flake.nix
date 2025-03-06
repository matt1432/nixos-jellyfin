{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
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
        (import nixpkgs {inherit system;})
        (import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        }));
  in {
    packages =
      perSystemWithCUDA (pkgs: cudaPkgs:
        import ./pkgs {inherit self pkgs cudaPkgs;});

    nixosModules = {
      jellyfin = import ./modules self.packages;

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
