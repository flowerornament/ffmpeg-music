#!/bin/sh
# Atlas: named tables inside libavcodec, each looped as one wavetable period at 110 Hz (declared -ar = 110*N).
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
ffmpeg -hide_banner -y \
 -f f32le -ar 112640 -ac 1 -i "subfile,,start,$((0xe1a0b0)),end,$((0xe1a0b0+4096)),,:$A" \
 -f s32le -ar 29040 -ac 1 -i "subfile,,start,$((0xd93e78)),end,$((0xd93e78+1056)),,:$A" \
 -f f32le -ar 211200 -ac 1 -i "subfile,,start,$((0xc11e80)),end,$((0xc11e80+7680)),,:$A" \
 -f f32le -ar 70400 -ac 1 -i "subfile,,start,$((0xc0a640)),end,$((0xc0a640+2560)),,:$A" \
 -f s16le -ar 56320 -ac 1 -i "subfile,,start,$((0xcc09f0)),end,$((0xcc09f0+1024)),,:$A" \
 -f s32le -ar 90310 -ac 1 -i "subfile,,start,$((0xd8b548)),end,$((0xd8b548+32768)),,:$A" \
 -filter_complex "
[0]aloop=-1:1024,aresample=48000,atrim=0:1.5[a];
[1]aloop=-1:264,aresample=48000,atrim=0:1.5[b];
[2]aloop=-1:1920,aresample=48000,atrim=0:1.5[c];
[3]aloop=-1:640,aresample=48000,atrim=0:1.5[d];
[4]aloop=-1:512,aresample=48000,atrim=0:1.5[e];
[5]aloop=-1:8192,aresample=48000,atrim=0:1.5[f];
[a][b][c][d][e][f]concat=n=6:v=0:a=1,highpass=f=20,dynaudnorm=f=100,volume=0.5" "$@"
