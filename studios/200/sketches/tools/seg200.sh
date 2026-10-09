#!/bin/sh
# seg200.sh in.wav out.png start dur [stopHz]  -- zoomed spectrogram + waveform of a segment
ffmpeg -hide_banner -loglevel error -y -ss "$3" -t "$4" -i "$1" -filter_complex "aformat=channel_layouts=mono,asplit[a][b];[a]showspectrumpic=size=1000x300:legend=0:color=magma:scale=log:fscale=log:stop=${5:-0}[s];[b]showwavespic=size=1000x120:colors=white[w];[s][w]vstack" "$2"
