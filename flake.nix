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
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem = attrs:
      nixpkgs.lib.genAttrs supportedSystems (system:
        attrs system nixpkgs.legacyPackages.${system});
  in {
    packages =
      perSystem (system: pkgs:
        import ./pkgs {inherit self system pkgs;});

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
