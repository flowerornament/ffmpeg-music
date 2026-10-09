#!/bin/bash
# look.sh file.wav|mp3 [start] [dur] [stopHz] [lin|log]  ->  file-look.png
# Waveforms (L,R) over spectrograms (L,R) of a window: the closest thing to ears in this studio.
f="$1"; ss=${2:-0}; d=${3:-8}; stop=${4:-0}; fs=${5:-lin}
ffmpeg -hide_banner -loglevel error -y -ss $ss -t $d -i "$f" -filter_complex "asplit[a][b];[a]showwavespic=s=1200x200:split_channels=1:scale=sqrt[w];[b]showspectrumpic=s=1200x500:legend=0:color=magma:scale=log:fscale=$fs:mode=separate:stop=$stop:drange=90,scale=1200x500[s];[w][s]vstack" "${f%.*}-look.png" && echo "${f%.*}-look.png"
