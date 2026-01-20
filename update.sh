#!/usr/bin/env -S nix develop .#update -c bash

updateJellyfin() {
    sed -i 's/assert finalAttrs.version/# assert finalAttrs.version/' ./pkgs/jellyfin/default.nix
    script="$(nix eval --raw .#jellyfin.updateScript)"
    $script "$@"
    sed -i 's/# assert finalAttrs.version/assert finalAttrs.version/' ./pkgs/jellyfin/default.nix
}

if [[ "$1" == "--commit" ]]; then
    git config --global user.name 'github-actions[bot]'
    git config --global user.email '41898282+github-actions[bot]@users.noreply.github.com'

    nix flake update

    git add ./flake.lock
    git commit -m "chore: update flake.lock"

    updateJellyfin --commit
    nix-update --flake "jellyfin-web" --commit
    nix-update --flake "jellyfin-desktop" --commit
    nix-update --flake "jellyfin-ffmpeg" --commit --override-filename ./pkgs/jellyfin-ffmpeg/default.nix

    git restore .
else
    updateJellyfin
    nix-update --flake "jellyfin-web"
    nix-update --flake "jellyfin-desktop"
    nix-update --flake "jellyfin-ffmpeg" --override-filename ./pkgs/jellyfin-ffmpeg/default.nix
fi
