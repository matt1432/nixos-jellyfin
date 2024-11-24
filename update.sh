#!/usr/bin/env -S nix develop .#update -c bash

COMMIT="$1"
ROOT_DIR="$(pwd)"

git_push() {
    if [[ "$COMMIT" == "--commit" ]]; then
        (
            cd "$ROOT_DIR" || return
            git config --global user.name 'Updater'
            git config --global user.email 'robot@nowhere.invalid'
            git remote update

            alejandra -q .
            git add .

            git commit -m "$1"
            git push
        )
    else
        echo "$1"
    fi
}

updatePackage() {
    script="$(nix eval --raw .#"$1".updateScript)"
    $script "${@:2}"
}

updatePackage "jellyfin"
updatePackage "jellyfin-web"
updatePackage "jellyfin-media-player"
updatePackage "jellyfin-ffmpeg"
