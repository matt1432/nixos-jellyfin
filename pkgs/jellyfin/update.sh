#!/usr/bin/env -S nix develop .#update -c bash

nix-update --flake jellyfin

depsFile="./pkgs/jellyfin/nuget-deps.nix"

fetchDeps=$(nix build .#jellyfin.fetch-deps --print-out-paths --no-link)
rm -rf "$depsFile"
$fetchDeps "$depsFile"

alejandra -q .

git add "$depsFile"

git restore ./pkgs/jellyfin/default.nix

nix-update --flake jellyfin "$@"
