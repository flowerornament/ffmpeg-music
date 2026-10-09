#!/bin/sh
# spec200.sh in.wav out.png [WxH]  -- log-freq spectrogram, studio 200's eyes
ffmpeg -hide_banner -loglevel error -y -i "$1" -lavfi "showspectrumpic=size=${3:-1000x350}:legend=1:color=magma:scale=log:fscale=log" "$2"
