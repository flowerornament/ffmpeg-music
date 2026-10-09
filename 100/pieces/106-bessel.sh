#!/bin/sh
# 106 — Bessel                                           (studio 100 · RASTRUM)
#
# One number per layer turns a beat into a roll.
# Raster: sample_rate 30074, FFT 65536 -> row k = k*0.45889 Hz, one column = one bar of
# 2.179 s (110.1 bpm), rect window, no overlap. Every layer is a comb (pulses per bar) with
# its own spectral shape. Then a sine is added to the phase across rows: beta*sin(2*pi*k/P).
# Since exp(i*beta*sin x) = sum_n J_n(beta) exp(i*n*x), every hit becomes a train of copies
# n/P of a bar apart, weighted by Bessel functions J_n(beta): beta=0 a single hit, beta=1 a
# flam, beta=3 a roll. At beta=2.405 J_0 vanishes: the hit itself disappears and only the
# roll around it remains -- a ghosted downbeat. At 3.83 the first neighbours vanish too.
#   kick   comb 4, log-phase chirp, P=16: four-on-the-floor that rolls and ghosts
#   snare  comb 2 on 2 and 4, P=24 (triplet flams)
#   hats   comb 8 offbeat, P=32
#   chords plucked Dm7 Bbmaj7 Gm7 A7 (equal tempered, rows rounded to 0.46 Hz), comb 4 offset
#          to each carrier so the pitch stays exact; P=16 so plucks bloom into mandolin rolls
#   bass   comb 2 on the roots, P=8
# Each layer's beta follows its own score (per bar), so the groove breathes.
W=72
SR=30074
F=0.45889
K="(32767-mod(Y,32768))"
LEFT="gte(Y,32768)"
B="X"
C="mod(floor($B/2),4)"
# beta scores (per bar)
BK="if(lt($B,16),0,if(lt($B,24),2.405*eq(mod($B,4),3),if(lt($B,40),1.2+1.2*sin(2*PI*$B/8),if(lt($B,48),2.405,if(lt($B,64),0.6*eq(mod($B,2),1)+2.405*eq(mod($B,8),7),0)))))"
BS="if(lt($B,24),0.3,1.8*(0.5-0.5*cos(2*PI*($B-24)/16)))"
BH="0.4+2.6*(0.5-0.5*cos(2*PI*$B/12))"
BC="if(lt($B,8),0,if(lt($B,40),2.2*(0.5-0.5*cos(2*PI*($B-8)/32)),if(lt($B,48),3.83,1.5*(0.5-0.5*cos(2*PI*$B/6)))))"
BB="if(lt($B,32),0.5,if(lt($B,48),1.6,0.8))"
# chord tones in semitones from D3 (146.83 Hz): Dm7 0 3 7 10 | Bbmaj7 0 3 7 8 | Gm7 0 3 5 8 | A7 -1 2 5 7
S1="(0-eq($C,3))"
S2="(3-eq($C,3))"
S3="(7-2*eq($C,2)-2*eq($C,3))"
S4="(10-2*eq($C,1)-2*eq($C,2)-3*eq($C,3))"
ROOT="(-12-4*eq($C,1)-7*eq($C,2)-5*eq($C,3))"
ROW="round(146.83*pow(2,_S_/12)/$F)"
# plucked voice: comb _H_ offset to carrier, Lorentzian width _G_, Bessel roll (beta _BE_, period _P_), pan _PN_
PL="st(4,_C_);if(eq(mod($K-ld(4),_H_),0)*lt(abs($K-ld(4)),30*_G_),st(1,($K-ld(4))/_G_);st(2,_A_*if($LEFT,cos(_PN_*PI/2),sin(_PN_*PI/2))/sqrt(1+ld(1)*ld(1)));st(3,-atan(ld(1))+_BE_*sin(2*PI*$K/_P_)-2*PI*$K*_T_);st(8,ld(8)+ld(2)*cos(ld(3)));st(9,ld(9)+ld(2)*sin(ld(3))),0)"
TONE="(${PL});(${PL//_C_/2*_C_});(${PL//_C_/3*_C_})"
CHV="${TONE//_H_/4}"; CHV="${CHV//_G_/2.2}"; CHV="${CHV//_BE_/$BC}"; CHV="${CHV//_P_/16}"; CHV="${CHV//_T_/0}"
CH1="${CHV//_C_/${ROW//_S_/$S1}}"; CH1="${CH1//_PN_/0.15}"
CH2="${CHV//_C_/${ROW//_S_/$S2}}"; CH2="${CH2//_PN_/0.85}"
CH3="${CHV//_C_/${ROW//_S_/$S3}}"; CH3="${CH3//_PN_/0.35}"
CH4="${CHV//_C_/${ROW//_S_/$S4}}"; CH4="${CH4//_PN_/0.65}"
CHORD="($CH1);($CH2);($CH3);($CH4)"; CHORD="${CHORD//_A_/0.022*between($B,4,67)}"
BASS="${TONE//_H_/2}"; BASS="${BASS//_G_/1.1}"; BASS="${BASS//_BE_/$BB}"; BASS="${BASS//_P_/8}"; BASS="${BASS//_T_/0}"
BASS="${BASS//_C_/${ROW//_S_/$ROOT}}"; BASS="${BASS//_PN_/0.5}"; BASS="${BASS//_A_/0.075*between($B,8,67)}"
MAG="st(8,0);st(9,0);_V_;max(0,255+2.125*8.6859*log(hypot(ld(8),ld(9))+1e-9))"
PHA="st(8,0);st(9,0);_V_;255*mod(atan2(ld(9),ld(8))/(2*PI)+0.5,1)"
SS="spectrumsynth=sample_rate=$SR:slide=fullframe:scale=log:win_func=rect:overlap=0"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x65536:d=1:r=1,format=gray,split[c0][c1];
[c0]geq=lum='${MAG//_V_/$CHORD}'[cm];[c1]geq=lum='${PHA//_V_/$CHORD}'[cp];
[cm][cp]$SS:channels=2,aresample=48000[chord];
color=c=black:s=${W}x65536:d=1:r=1,format=gray,split[b0][b1];
[b0]geq=lum='${MAG//_V_/$BASS}'[bm];[b1]geq=lum='${PHA//_V_/$BASS}'[bp];
[bm][bp]$SS:channels=2,aresample=48000[bass];
color=c=black:s=${W}x32768:d=1:r=1,format=gray,split[k0][k1];
[k0]geq=lum='eq(mod($K,4),0)*between($B,0,67)*max(0,255+2.125*(-30-8.7*pow(($K*$F-50)/26,2)))'[km];
[k1]geq=lum='255*mod(-2.2*log($K*$F+1)+($BK)*sin(2*PI*$K/16)/(2*PI),1)'[kp];
[km][kp]$SS:channels=1,aresample=48000,aformat=channel_layouts=mono,pan=stereo|c0=c0|c1=c0[kick];
color=c=black:s=${W}x32768:d=1:r=1,format=gray,split[s0][s1];
[s0]geq=lum='eq(mod($K,2),0)*between($B,16,67)*between($K,400,17000)*max(0,255+2.125*(-56-2.2*pow(log($K*$F/1100)/log(2),2)))'[sm];
[s1]geq=lum='255*mod(-$K/4-0.004*$K+0.5*(sin($K/57)+sin($K/91+2))+0.25*mod(sin($K*12.9898)*43758.5453,1)+($BS)*sin(2*PI*$K/24)/(2*PI),1)'[sp];
[sm][sp]$SS:channels=1,aresample=48000,aformat=channel_layouts=mono,pan=stereo|c0=0.85*c0|c1=c0[snare];
color=c=black:s=${W}x32768:d=1:r=1,format=gray,split[h0][h1];
[h0]geq=lum='eq(mod($K,8),0)*between($B,8,67)*gt($K,14000)*(255+2.125*(-57))'[hm];
[h1]geq=lum='255*mod(-$K/16+0.1*mod(sin($K*3.17)*43758.5453,1)+($BH)*sin(2*PI*$K/32)/(2*PI),1)'[hp];
[hm][hp]$SS:channels=1,aresample=48000,aformat=channel_layouts=mono,pan=stereo|c0=0.55*c0|c1=c0[hats];
aevalsrc=d=2.5:s=48000:exprs='(random(0)*2-1)*exp(-t*2.5)|(random(1)*2-1)*exp(-t*2.5)',lowpass=f=7000[ir];
[chord]asplit[cd][cw];[cw]highpass=f=250[cw1];[cw1][ir]afir=dry=0:wet=1[rev];
[cd][rev][bass][kick][snare][hats]amix=inputs=6:weights=1 0.3 1 1 1 1:normalize=0,
alimiter=limit=0.79:level=0,afade=t=out:st=142:d=4.9" "$@"
