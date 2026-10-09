#!/bin/sh
# dead end: adeclip on a chord clipped at a slowly rising level. Output = the chord + intermodulation (E2, G3), no hallucinated peaks. With w=100 a=25 it is extremely slow; on FM-rich square-ish material with t=1 it explodes into broadband noise.
ffmpeg -hide_banner -filter_complex "
aevalsrc=s=48000:d=6:exprs='st(1,0.3*sin(2*PI*110*t)+0.3*sin(2*PI*137.5*t)+0.3*sin(2*PI*165*t));st(2,0.05+0.4*t/6);min(max(ld(1),-ld(2)),ld(2))',adeclip=w=50:o=75:a=8:t=10:n=1000" "$@"
