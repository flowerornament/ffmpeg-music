#!/bin/sh
# x09 — the overtone ladder: frames K4..K13 (tools/gsmframes.py overtone k), each 1 s, at declared
# rate 4400 (drone A2 = 110 Hz) -> the whistle climbs harmonics 4..13 (440 .. 1430 Hz).
K4="038Hw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc038Hw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc038Hw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K5="1H8Pw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1H8Pw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1H8Pw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K6="1T8fw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1T8fw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1T8fw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K7="1f8vA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1f8vA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1f8vA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K8="1r8+A9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1r8+A9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1r8+A9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K9="139FQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc139FQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc139FQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K10="2D9Mw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2D9Mw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2D9Mw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K11="2P9cA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2P9cA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2P9cA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K12="2b9rQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2b9rQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2b9rQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K13="2n96g9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2n96g9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2n96g9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
p() { echo "amovie='data\\:application/octet-stream;base64,$1':f=gsm:format_opts='sample_rate=4400',asetpts=N/SR/TB,atrim=start_sample=320:end_sample=480,asetpts=N/SR/TB,aloop=-1:160,asetpts=N/SR/TB,aresample=48000,atrim=0:1,afade=t=in:d=0.03,afade=t=out:st=0.95:d=0.05"; }
ffmpeg -hide_banner -y -filter_complex "
$(p $K4)[a];$(p $K5)[b];$(p $K6)[c];$(p $K7)[d];$(p $K8)[e];$(p $K9)[f];$(p $K10)[g];$(p $K11)[h];$(p $K12)[i];$(p $K13)[j];
[a][b][c][d][e][f][g][h][i][j]concat=n=10:v=0:a=1,volume=0.4" "$@"
