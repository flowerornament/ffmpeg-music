#!/bin/bash
# look.sh file.wav [start] [dur] [fmax] -> file-z.png : linear-frequency spectrogram 0..fmax + waveform
f=$1; ffmpeg -hide_banner -loglevel error -y -ss ${2:-0} -t ${3:-5} -i "$f" -filter_complex "asplit[a][b];[a]showspectrumpic=s=900x360:legend=0:color=magma:scale=log:fscale=lin:start=0:stop=${4:-3000}:mode=combined[s];[b]showwavespic=s=900x120:split_channels=1[w];[s][w]vstack" "${f%.wav}-z.png"
