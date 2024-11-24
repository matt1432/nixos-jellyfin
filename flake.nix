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
        attrs (import nixpkgs {inherit system;}));
  in {
    packages =
      perSystem (pkgs:
        import ./pkgs {inherit self pkgs;});

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
              nix build .#jellyfin
              nix build .#jellyfin-web
              nix build .#jellyfin-media-player
              nix build .#jellyfin-ffmpeg
            '';
          })
        ];
      };
    });
  };
}
