#!/bin/bash
# spec.sh in.wav out.png [stopHz] [start] [dur]   (zoom by resampling to 2*stop)
s=$(( ${3:-8000} * 2 ))
ffmpeg -hide_banner -loglevel error -y -ss ${4:-0} -t ${5:-6} -i "$1" -lavfi "aformat=channel_layouts=mono,aresample=$s,showspectrumpic=s=700x300:legend=0:color=magma:scale=${6:-log}:fscale=lin" "$2"
