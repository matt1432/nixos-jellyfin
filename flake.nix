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
  }: let
    # TODO: see if jellyfin is supported on anything else
    supportedSystems = ["x86_64-linux"];

    perSystem = attrs:
      nixpkgs.lib.genAttrs supportedSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        attrs system pkgs);
  in {
    packages = perSystem (system: pkgs:
      import ./pkgs {
        inherit self system pkgs;
      });

    nixosModules = {
      jellyfin = import ./modules self.packages;

      default = self.nixosModules.jellyfin;
    };

    formatter = perSystem (_: pkgs: pkgs.alejandra);

    devShells = perSystem (_: pkgs: {
      update = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          bash
          common-updater-scripts
          git
          jq
          nix-prefetch-git
          nix-prefetch-github
          nix-prefetch-scripts
        ];
      };
    });
  };
}
