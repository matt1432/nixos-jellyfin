#!/usr/bin/env -S nix develop .#update -c bash

nix-update -F jellyfin "$@"

depsFile="./pkgs/jellyfin/nuget-deps.nix"

fetchDeps=$(nix build .#jellyfin.fetch-deps --print-out-paths --no-link)
rm -rf "$depsFile"
$fetchDeps "$depsFile"

alejandra -q .
