#!/bin/sh
# dynamics become rhythm: one note per second with random loudness, silenceremove cuts each tail at -36 dB; 40 s of input -> 13 s; louder notes last longer. Basis of 507.
# one note per second, amplitude from a hash; silenceremove cuts every tail at -36 dB
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=40:exprs='st(0,floor(t));st(1,t-ld(0));st(2,mod(sin(ld(0)*9.17)*43758.5453,1));st(3,220*pow(2,(floor((12*(mod(ld(0)*3,8)+5)+5)/7)-9)/12));pow(ld(2),2)*0.9*sin(2*PI*ld(3)*ld(1))*exp(-ld(1)*7)',
silenceremove=stop_periods=-1:stop_threshold=-36dB:stop_silence=0:stop_duration=0:detection=peak:window=0.002" "$@"
