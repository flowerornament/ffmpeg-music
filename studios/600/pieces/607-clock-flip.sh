#!/bin/sh
# 607 — clock_flip
# Studio 600 (Claude). Genre: Quarter-Turn. The opening of the record: the whole idea, unhidden.
#
# One picture per 4-bar phrase (384 x 384 of the time-frequency plane, 20 ms x 12.5 Hz pixels at
# 12800 Hz). It is played as drawn, then played after FFmpeg's own transpose=clock_flip, which
# swaps time and frequency exactly. Six pixels are a 16th note at 125 bpm and 75 Hz, so harmonic q
# becomes 16th-step q. Strokes are drawn above each harmonic row so that, swapped, they ring after
# the beat: early strokes (kick) fall low, late strokes (hat) rise high, chord rows become rims.
# Phrases: chord | the same picture flipped | chord | flipped | both at once | both, fading.
# Chords: 4:5:6 with octaves on harmonics 1, 5, 7, 3 of 75 Hz (D, F#, C-, A).
PH=7.68
M="floor(T/$PH+0.01)"
TRI=282578801202544
SCORE="st(0,512-Y);st(1,floor(ld(0)/6));st(2,ld(0)-6*ld(1));
 st(3,mod(floor(3751/pow(10,mod($M,4))),10));st(4,ld(1)/ld(3));
 lte(ld(0),383)*(
 eq(mod(ld(1),4),0)*(exp(-ld(2)/2)*exp(-pow((X-7+0.8*ld(2))/1.3,2))+eq(ld(2),0)*0.5*exp(-X/10))*40000
+eq(mod(ld(1),8),4)*lte(ld(2),3)*between(X,40,220)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2)/1.4)*7000
+eq(mod(ld(1),4),2)*lte(ld(2),1)*gte(X,250)*pow((X-250)/133,2)*11000
+eq(ld(2),0)*gte(ld(1),1)*eq(ld(4),floor(ld(4)))*lte(ld(4),48)*mod(floor($TRI/pow(2,ld(4))),2)*(0.35+0.65*exp(-X/120))*2500
+eq(ld(2),0)*between(ld(1),1,2)*3500)"
PU="65535*mod((H-1-Y)*(X+2)/4,1)"
PW="65535*mod((H-1-Y)*(X+2)/4+gt(H-1-Y,24)*0.15*mod(sin((H-1-Y)*91.7)*4375.85,1),1)"
SS="slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1"
n="floor(t/$PH+0.001)"
D=46.08
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$SCORE',split[s1][s2];
[s1]gblur=sigma=6:sigmaV=0.01,split[a1][a2];
[s2]crop=384:384:0:129,transpose=clock_flip,pad=384:513:0:129,split[b1][b2];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PU',split[p1][p2];
nullsrc=s=384x513:r=12800/98304:d=$D,format=gray16,geq=lum='$PW',split[w1][w2];
[a1][p1]spectrumsynth=sample_rate=12800:$SS[AL];[a2][w1]spectrumsynth=sample_rate=12800:$SS[AR];
[b1][p2]spectrumsynth=sample_rate=12800:$SS[BL];[b2][w2]spectrumsynth=sample_rate=12800:$SS[BR];
[AL][AR]amerge,aresample=48000,highpass=f=35,volume='0.55*not(mod($n,2))*lt($n,4)+0.35*gte($n,4)':eval=frame[A];
[BL][BR]amerge,aresample=48000,highpass=f=30,volume='1.3*(mod($n,2)*lt($n,4)+gte($n,4))':eval=frame[B];
[A][B]amix=inputs=2:normalize=0,acompressor=threshold=0.5:ratio=2:attack=20:release=250,volume=1.3,
 alimiter=limit=0.85,volume=0.92,afade=t=in:d=0.3,afade=t=out:st=38:d=8" -t $D "$@"
