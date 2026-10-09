#!/bin/sh
# 307 — Two Flashes (PHI, opening of "What Moved")
# Wertheimer, 1912: two lights, flashed one after the other, seen as one light moving.
# Two chords alternate every 3 s (just: 24 30 36 48 45 | 20 25 32 40 54, bins = harmonics of
# 11.71875 Hz). minterpolate computes the motion between them all along, but at first we only
# let through the frames at the keyframes: two flashes, silence between. Over a minute the
# window of admitted in-between frames widens, until no frame is missing and the two chords
# have become one thing moving: the interpolated glides, the phi phenomenon, made audible.
# Left ear: exhaustive search. Right ear: bilateral three-step, 8px blocks.
F=46.875
DRAW="st(0,H-1-Y);st(9,mod(N,2));
st(1,if(ld(9),20,24));st(2,if(ld(9),25,30));st(3,if(ld(9),32,36));st(4,if(ld(9),40,48));st(5,if(ld(9),54,45));
st(6,0);st(7,1);while(lte(ld(7),8),st(6,ld(6)+(1.3*exp(-pow((ld(0)-ld(1)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(2)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(3)*ld(7))/1.2,2))
 +exp(-pow((ld(0)-ld(4)*ld(7))/1.2,2))+0.7*exp(-pow((ld(0)-ld(5)*ld(7))/1.2,2)))/ld(7));st(7,ld(7)+1));
min(255,170*ld(6))"
# admitted window around each keyframe: half-width grows 0.12 s -> 1.6 s (= everything) by 58 s
GATE="st(1,mod(T+1.5,3)-1.5);st(2,0.12+1.5*pow(clip((T-6)/52,0,1),1.6));
p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*0.11*clip((ld(2)-abs(ld(1)))/0.06,0,1)"
PHASE="255*mod((H-1-Y)*N/4+sin((H-1-Y)*12.9898)*43758.5453,1)"
SYN="spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75,aformat=channel_layouts=mono"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=32x2049:r=1/3:d=81,format=gray,geq=lum='$DRAW',settb=1/1000,split[k1][k2];
[k1]minterpolate=fps=$F:mi_mode=mci:scd=none:me_mode=bidir:me=esa:search_param=32,format=gray,crop=1:2049:16:0,geq=lum='$GATE'[mL];
[k2]minterpolate=fps=$F:mi_mode=mci:scd=none:me_mode=bilat:me=tss:mb_size=8,format=gray,crop=1:2049:16:0,geq=lum='$GATE'[mR];
color=c=black:s=1x2049:r=$F:d=81,format=gray,geq=lum='$PHASE',split[pL][pR];
[mL][pL]$SYN[l];[mR][pR]$SYN[r];
[l][r]join=inputs=2:channel_layout=stereo,atrim=0:72,asplit[dry][w];
aevalsrc=d=5:s=48000:exprs='(random(0)*2-1)*exp(-t*1.1)|(random(1)*2-1)*exp(-t*1.1)',lowpass=f=6000[ir];
[w]highpass=f=150[w2];[w2][ir]afir=dry=1:wet=1[wet];
[dry][wet]amix=inputs=2:weights=1 0.35:normalize=0,highpass=f=25,
 acompressor=threshold=0.2:ratio=2:attack=20:release=300,volume=1.4,alimiter=limit=0.89:level=0,
 afade=t=out:st=66:d=6
" "$@"
