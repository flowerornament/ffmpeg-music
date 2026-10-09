#!/bin/sh
# surround upmixer as common-tone extractor: L = A major, R = F# minor; FC gets A and C# (shared), F#/E ~26-33 dB down. Basis of 506.
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=4:c=stereo:exprs='0.2*(sin(2*PI*220*t)+sin(2*PI*277.18*t)+sin(2*PI*329.63*t))|0.2*(sin(2*PI*185*t)+sin(2*PI*220*t)+sin(2*PI*277.18*t))',surround=chl_out=5.1,pan=stereo|c0=c2|c1=c2" "$@"
