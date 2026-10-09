#!/bin/sh
# 004 — ffmpeg Reads Itself (scratch sketch B, kept because the listener liked it)
# The instrument's own machine code, interpreted as unsigned 8-bit mono at 22.05 kHz.
ffmpeg -hide_banner -y -f u8 -ar 22050 -ac 1 -i "${FFMPEG_MUSIC_BIN:-/nix/store/vil0k7wdg0jwyqc9kvg9dycsf65w4s4f-ffmpeg-9.0.1-bin/bin/ffmpeg}" -t 20 -af "volume=0.3" "$@"
