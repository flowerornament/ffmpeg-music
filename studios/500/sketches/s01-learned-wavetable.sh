#!/bin/sh
# learned wavetable: impulse train x (period 400 = 120 Hz) teaches anlms nothing but timing; target d changes waveform every 3 s (saw, odd harmonics, FM, pulse). out_mode=e. At mu .05 each harmonic fades at its own rate with diagonal interference bands — a morph unlike a crossfade. Try mu .002 (slow bloom) and .5.
ffmpeg -hide_banner -filter_complex "
aevalsrc=s=48000:d=12:exprs='eq(mod(n,400),0)'[x];
aevalsrc=s=48000:d=12:exprs='st(1,floor(t/3));st(2,mod(n,400)/400);0.3*if(eq(ld(1),0),2*ld(2)-1,if(eq(ld(1),1),sin(2*PI*ld(2))+sin(6*PI*ld(2))/3+sin(10*PI*ld(2))/5,if(eq(ld(1),2),sin(2*PI*ld(2)+3*sin(4*PI*ld(2))),gt(ld(2),0.2)*2-1)))'[d];
[x][d]anlms=order=512:mu=0.05:out_mode=e" "$@"
