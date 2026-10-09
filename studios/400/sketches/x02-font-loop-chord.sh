#!/bin/sh
F=/System/Library/Fonts/Geneva.ttf
ffmpeg -hide_banner -y -f u8 -ar 48000 -ac 1 -i $F -filter_complex "
[0]asplit=4[a][b][c][d];
[a]atrim=start_sample=200000,asetpts=N/SR/TB,aloop=loop=-1:size=480,atrim=duration=8[a1];
[b]atrim=start_sample=300000,asetpts=N/SR/TB,aloop=loop=-1:size=384,atrim=duration=8[b1];
[c]atrim=start_sample=400000,asetpts=N/SR/TB,aloop=loop=-1:size=320,atrim=duration=8[c1];
[d]atrim=start_sample=500000,asetpts=N/SR/TB,aloop=loop=-1:size=240,atrim=duration=8[d1];
[a1][b1][c1][d1]amix=inputs=4,highpass=f=40,volume=0.5" "$@"
