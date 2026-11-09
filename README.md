# Marco Bonetti's NixOS Configuration

This is my personal configuration, it uses [Flakes](https://wiki.nixos.org/wiki/Flakes), and it's made to handle both my Desktop PC and my Laptop, it's impermanent (via [Preservation](https://github.com/nix-community/preservation)), it uses [Hyprland](https://hypr.land/) as the window manager (configured to use the [Caelestia Shell](https://github.com/caelestia-dots/shell) for theming) and handles the userspace through [Home Manager](https://wiki.nixos.org/wiki/Home_Manager).

## Hosts

Hosts specific configuration are located inside the `hosts/` directory:

| Hostname | Hardware |
| :--- | :--- |
| **`leto-ii`** | Desktop PC |
| **`ghanima`** | Laptop PC |

## Keybinds

Werever possible, vim-style keybinds are used.

## Wallpapers

They are downloaded from my [Wallhaven](https://wallhaven.cc) profile through the `download-wallpapers.sh` script.
