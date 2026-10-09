#!/bin/sh
# 108 — Rhythmicon                                       (studio 100 · RASTRUM)
#
# The overture: the raster introduces itself.
# sample_rate 28160, 32768 rows per ear -> row k = k*0.4297 Hz; rect window, no overlap, one
# column = one bar of 2.327 s. Voice h (h = 1..16) is the h-th harmonic of A1 = 55 Hz (row
# 128*h) and is plucked h times per bar: a comb of rows spaced h around its carrier, each tooth
# weighted 1/sqrt(1+x^2) with phase -atan(x) (an exact damped-sine pluck).
# One voice enters per bar, 1, 2, 3 ... 16, as on the machine Theremin built for Henry Cowell
# in 1931 -- except that here the sixteen rhythms are also, exactly, the sixteen partials of
# one low A. No voice has overtones of its own: the voices are each other's overtones.
# Bars 17-19 all sixteen. Bars 20-21 every voice is struck once, together, and rings.
# Odd harmonics lean left, even ones right.
W=24
K="(32767-mod(Y,32768))"
LEFT="gte(Y,32768)"
B="X"
FREE="between($B,20,21)"
H="round($K/128)"
# one pixel belongs to at most one voice: h = nearest multiple of 128
V="st(1,$H);st(2,if($FREE,1,ld(1)));st(3,(1.3+0.08*ld(1))*(1+2*$FREE));st(4,($K-128*ld(1))/ld(3));
st(5,between(ld(1),1,min(16,$B+1))*lt($B,22)*eq(mod($K-128*ld(1),ld(2)),0)*lt(abs(ld(4)),40))"
PAN="if($LEFT,1-0.55*eq(mod(ld(1),2),0),1-0.55*eq(mod(ld(1),2),1))"
MAG="$V;if(ld(5),max(0,255+2.125*(-21-3*log(ld(1))/log(2)-10*log(1+ld(4)*ld(4))/log(10)+8.6859*log($PAN))),0)"
PHA="$V;255*mod(-atan(ld(4))/(2*PI)+0.5,1)"
SS="spectrumsynth=sample_rate=28160:channels=2:slide=fullframe:scale=log:win_func=rect:overlap=0"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x65536:d=1:r=1,format=gray,geq=lum='$MAG'[m];
color=c=black:s=${W}x65536:d=1:r=1,format=gray,geq=lum='$PHA'[p];
[m][p]$SS,aresample=48000,asplit[dry][w0];
aevalsrc=d=4:s=48000:exprs='(random(0)*2-1)*exp(-t*1.4)|(random(1)*2-1)*exp(-t*1.4)',lowpass=f=6000[ir];
[w0]highpass=f=200[w1];[w1][ir]afir=dry=0:wet=1[rev];
[dry][rev]amix=inputs=2:weights=1 0.3:normalize=0,alimiter=limit=0.79:level=0,afade=t=out:st=50:d=5.8" "$@"
