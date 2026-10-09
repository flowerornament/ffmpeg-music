#!/bin/sh
# differential music: x = d delayed exactly one bar; out_mode=o (error). Bars 0-7 identical (vanish after bar 1), bar 8 changes one note: you hear the new note + an inverted ghost of the old. NLMS converges in 1-2 bars at any mu, so it is close to a comb d[n]-d[n-P]. Parked.
# bar = 96000 samples (2 s), step = 6000 samples. bars 0-7 identical, bar 8+ one note changed
S="st(0,floor(n/6000));st(1,(n-ld(0)*6000)/48000);st(2,mod(ld(0),16));st(3,floor(ld(0)/16));st(4,mod(floor(4201234/pow(10,mod(ld(2),7))),10)+if(gte(ld(3),8)*eq(ld(2),5),3,0));st(5,220*pow(2,(floor((12*(ld(4)+5)+5)/7)-9)/12));0.3*sin(2*PI*ld(5)*ld(1))*exp(-ld(1)*8)+eq(mod(ld(2),4),0)*0.5*sin(2*PI*(50+90*exp(-ld(1)*30))*ld(1))*exp(-ld(1)*9)"
ffmpeg -hide_banner -filter_complex "aevalsrc=s=48000:d=32:exprs='$S',asplit[d][x0];[x0]adelay=96000S[x];[x][d]anlms=order=32:mu=0.01:out_mode=o" "$@"
