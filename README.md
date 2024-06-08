# NixOS Jellyfin

This is a Nix flake containing most packages released by the [Jellyfin](https://github.com/jellyfin) org.
It also has a module for the Jellyfin [server](https://github.com/jellyfin/jellyfin) that allows you to
manage a Jellyfin instance declaratively in nix code.

## Packages

This flake exposes multiple Jellyfin packages with the latest stable release
(the version you get when running `curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r .tag_name`)

Most of the nix code for these packages has been taken from nixpkgs, but gets updated automatically every day
so I get updates way before nixpkgs does.

- [jellyfin](https://github.com/jellyfin/jellyfin):
The basic server package

- [jellyfin-web](https://github.com/jellyfin/jellyfin-web):
The `web` package that acts as the frontend

- [jellyfin-ffmpeg](https://github.com/jellyfin/jellyfin-ffmpeg):
The ffmpeg package forked by the jellyfin team

- [jellyfin-media-player](https://github.com/jellyfin/jellyfin-media-player):
The desktop client

## Module
The module exposed by this flake adds more options to the [nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/jellyfin.nix)
one and uses this flake's packages by default.

It also allows you to declare settings found in Jellyfin's dashboard in
`services.jellyfin.settings`. If you do use this, the changes you do in
the dashboard will be overwritten by these ones on every restart.

I also can't guarantee these will always work because of how Jellyfin's
config files can change after updates. You can take a look at how I make
use of these settings [here](https://git.nelim.org/matt1432/nixos-configs/src/commit/29bc56e7492c5d2310016d5aed612a8fb4a5b127/devices/nos/modules/jellyfin/default.nix#L33).
