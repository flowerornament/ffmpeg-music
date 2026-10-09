#!/bin/sh
# x10 — stateful decoders as oscillators: AAC codebook 5 (81 bytes) looped with -stream_loop and
# decoded as DFPWM (1-bit delta modulation): periodic at 48000/648 = 74 Hz, timbre = the
# decoder's adaptation to the bit pattern. Try -f gsm / g722 too (gsm on arbitrary bytes = harsh noise:
# it only becomes musical when you write the frames yourself, see x08).
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
B=$((0xc0d558+324))
ffmpeg -hide_banner -y -stream_loop -1 -f dfpwm -ar 48000 -ac 1 -i "subfile,,start,$B,end,$((B+81)),,:$A" -t 6 -af "highpass=f=30,volume=0.5" "$@"
