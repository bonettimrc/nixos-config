#!/usr/bin/env bash
# Native messaging host for CaelestiaFox. Forwards ~/.local/state/caelestia/scheme.json
# to the extension every time it changes, using Firefox's native-messaging wire format
# (a 4-byte little-endian length prefix followed by the raw message bytes).
set -euo pipefail

scheme="${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json"

send() {
    local msg len
    msg=$(<"$scheme")
    len=$(printf '%08x' "${#msg}")
    printf '%b' "\\x${len:6:2}\\x${len:4:2}\\x${len:2:2}\\x${len:0:2}"
    printf '%s' "$msg"
}

[[ -f "$scheme" ]] && send

inotifywait -qm -e close_write,moved_to,create "$(dirname "$scheme")" |
    while read -r _ _ file; do
        [[ "$file" == "scheme.json" ]] && send
    done

