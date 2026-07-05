#!/usr/bin/env -S nix develop .#update -c bash

updateJellyfin() {
    script="$(nix eval --raw .#jellyfin.updateScript)"
    $script "$@"
}

if [[ "$1" == "--commit" ]]; then
    head_before=$(git rev-parse HEAD)

    git config --global user.name 'github-actions[bot]'
    git config --global user.email '41898282+github-actions[bot]@users.noreply.github.com'

    updateJellyfin --commit
    nix-update --flake "jellyfin-web" --commit
    nix-update --flake "jellyfin-desktop" --commit
    nix-update --flake "jellyfin-ffmpeg" --commit --override-filename ./pkgs/jellyfin-ffmpeg/default.nix

    git restore .

    if [[ "$(git rev-parse HEAD)" != "$head_before" ]]; then
        nix flake update
        git commit -am "chore: update flake.lock"
    fi
else
    updateJellyfin
    nix-update --flake "jellyfin-web"
    nix-update --flake "jellyfin-desktop"
    nix-update --flake "jellyfin-ffmpeg" --override-filename ./pkgs/jellyfin-ffmpeg/default.nix
fi
