{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem = attrs:
      nixpkgs.lib.genAttrs supportedSystems (system:
        attrs (import nixpkgs {inherit system;}) (import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        }));
  in {
    packages =
      perSystem (pkgs: cudaPkgs:
        import ./pkgs {inherit self pkgs cudaPkgs;});

    nixosModules = {
      jellyfin = import ./modules self.packages;

      default = self.nixosModules.jellyfin;
    };

    formatter = perSystem (pkgs: cudaPkgs: pkgs.alejandra);

    devShells = perSystem (pkgs: cudaPkgs: {
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
