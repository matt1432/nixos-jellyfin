#!/usr/bin/env -S nix develop .#update -c bash

updatePackage() {
    script="$(nix eval --raw .#"$1".updateScript)"
    $script "${@:2}"
}

if [[ "$1" == "--commit" ]]; then
    git config --global user.name 'github-actions[bot]'
    git config --global user.email '41898282+github-actions[bot]@users.noreply.github.com'

    nix flake update

    git add ./flake.lock
    git commit -m "chore: update flake.lock"

    updatePackage "jellyfin" --commit
    nix-update --flake "jellyfin-web" --commit
    # nix-update --flake "jellyfin-media-player" --commit
    nix-update --flake "jellyfin-ffmpeg" --commit

    git restore .
else
    updatePackage "jellyfin"
    nix-update --flake "jellyfin-web"
    # nix-update --flake "jellyfin-media-player"
    nix-update --flake "jellyfin-ffmpeg"
fi
