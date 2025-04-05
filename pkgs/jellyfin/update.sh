#!/usr/bin/env -S nix develop .#update -c bash

# TODO: fix nuget deps in nix-update
commit_msg="$(nix-update --src-only --flake jellyfin "${@:2}" --write-commit-message >(tail -f -) > /dev/null)"

depsFile="./pkgs/jellyfin/nuget-deps.json"

fetchDeps=$(nix build .#jellyfin.fetch-deps --print-out-paths --no-link)
rm -rf "$depsFile"
$fetchDeps "$depsFile"

echo "$commit_msg"

if [[ "$1" == "--commit" ]] && [[ "$commit_msg" != "" ]]; then
    git add ./flake.lock
    git commit -m "chore: update flake.lock"

    git add "$depsFile" ./pkgs/jellyfin/default.nix
    git commit -m "$commit_msg"
fi
