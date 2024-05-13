{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    jellyfin-src = {
      type = "github";
      owner = "jellyfin";
      repo = "jellyfin";
      ref = "v10.9.1";
      flake = false;
    };

    jellyfin-web-src = {
      type = "github";
      owner = "jellyfin";
      repo = "jellyfin-web";
      ref = "v10.9.1";
      flake = false;
    };
  };

  outputs = {
    self,
    jellyfin-src,
    jellyfin-web-src,
    nixpkgs,
  }: let
    # TODO: see if jellyfin is supported on anything else
    supportedSystems = ["x86_64-linux"];

    perSystem = attrs:
      nixpkgs.lib.genAttrs supportedSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        attrs system pkgs);
  in {
    packages = perSystem (system: pkgs: {
      jellyfin-web = pkgs.callPackage ./pkgs/web.nix {
        inherit jellyfin-web-src;
      };
      jellyfin = pkgs.callPackage ./pkgs {
        inherit (self.packages.${system}) jellyfin-web;
        inherit jellyfin-src;
      };

      # Not sure if this actually does anything
      cudaPackages = {
        jellyfin-web = pkgs.cudaPackages.callPackage ./pkgs/web.nix {
          inherit jellyfin-web-src;
        };
        jellyfin = pkgs.cudaPackages.callPackage ./pkgs {
          inherit (self.packages.${system}.cudaPackages) jellyfin-web;
          inherit jellyfin-src;
        };
      };
    });

    nixosModules = {
      jellyfin = import ./modules self.packages;

      default = self.nixosModules.jellyfin;
    };

    formatter = perSystem (_: pkgs: pkgs.alejandra);

    devShells = perSystem (_: pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
        ];
      };
    });
  };
}
