#!/usr/bin/env -S nix develop .#update -c bash

COMMIT="$1"
ROOT_DIR="$(pwd)"

updatePackage() {
    script="$(nix eval --raw .#"$1".updateScript)"
    $script "${@:2}"
}

if [[ "$COMMIT" == "--commit" ]]; then
    cd "$ROOT_DIR" || return

    git config --global user.name 'Updater'
    git config --global user.email 'robot@nowhere.invalid'
    git remote update

    updatePackage "jellyfin" --commit
    updatePackage "jellyfin-web" --commit
    updatePackage "jellyfin-media-player" --commit
    updatePackage "jellyfin-ffmpeg" --commit
else
    updatePackage "jellyfin"
    updatePackage "jellyfin-web"
    updatePackage "jellyfin-media-player"
    updatePackage "jellyfin-ffmpeg"
fi
