#!/bin/sh
# 102 — Overtone Meter                                   (studio 100 · RASTRUM)
#
# One fundamental for everything. spectrumsynth turns a picture into sound by inverse FFT;
# with sample_rate 28160 and 32768 rows (FFT 65536) every row k is the k-th harmonic of
# F = 28160/65536 = 0.4297 Hz, and one column with a rect window and no overlap lasts exactly
# 1/F = 2.327 s. So the bar IS the fundamental: the score image is one column per bar.
#
# The law of the piece: harmonic h is struck h times per bar. A voice is the set of rows
# that are multiples of h (a comb = h pulses per bar) lit around the carrier row h*2^o
# (its pitch = h*2^o*F). Magnitude 1/sqrt(1+x^2), phase -atan(x), x=(k-c)/g is the exact
# Fourier series of a damped sine re-struck every 1/(hF): a pluck. So a chord of harmonics
# {8,10,12} (A C# E) is also the polyrhythm 8:10:12, and the bass line 4,5,6,7 (A C# E G-)
# is also the tempo line quarter notes, quintuplets, sextuplets, septuplets against the kick.
#   kick   comb 4, phase -2.2 ln f  (group delay ~ 1/f: a downward chirp)
#   snare  comb 2, delayed 1/4 bar, smooth random phase (dispersion smears the click to a burst)
#   hats   comb 8, delayed 1/16 bar; a sine in the phase across rows makes Bessel ratchets
#   pad    comb 1 with +atan phase: time-reversed plucks swelling into each next chord
# Tuning: harmonic series of A (A=110 Hz at harmonic 256). Tempo 103.1 bpm. Same number.
W=80
K="(32767-mod(Y,32768))"
LEFT="gte(Y,32768)"
B="X"
C="mod(floor($B/2),4)"
V1="(8+2*eq($C,1)+4*eq($C,2)+2*eq($C,3))"
V2="(10+2*eq($C,1)+5*eq($C,2)+4*eq($C,3))"
V3="(12+3*eq($C,1)+6*eq($C,2)+6*eq($C,3))"
NXT="mod(floor(($B+1)/2),4)"
# section gates (bars): intro 0-7, verse 8-15, full 16-47, break 48-55, full 56-71, outro 72-79
GK="(between($B,16,47)+between($B,56,71))"
GS="(between($B,24,47)+between($B,58,71))"
GH="(between($B,16,47)+between($B,52,73))"
GB="between($B,8,75)"
GO="(between($B,40,47)+between($B,56,71))"
# one plucked voice: comb _H_, carrier _C_, width _G_ rows, amplitude _A_ (linear), pan _P_ (0=L..1=R)
PL="if(eq(mod($K,_H_),0)*lt(abs($K-_C_),30*_G_),st(1,($K-_C_)/_G_);st(2,_A_*if($LEFT,cos(_P_*PI/2),sin(_P_*PI/2))/sqrt(1+ld(1)*ld(1)));st(3,-atan(ld(1)));st(8,ld(8)+ld(2)*cos(ld(3)));st(9,ld(9)+ld(2)*sin(ld(3))),0)"
TONE="${PL}+${PL//_C_/2*_C_}+${PL//_C_/3*_C_}"
# chord voices: in the intro and the outro every voice is struck once per bar (comb 1, long ring);
# from bar 8 to 75 the law holds and harmonic h is struck h times per bar.
FREE="(lt($B,8)+gte($B,76))"
CH1="${TONE//_H_/if($FREE,1,$V1)}"; CH1="${CH1//_C_/$V1*64}"; CH1="${CH1//_P_/0.2}"
CH2="${TONE//_H_/if($FREE,1,$V2)}"; CH2="${CH2//_C_/$V2*64}"; CH2="${CH2//_P_/0.8}"
CH3="${TONE//_H_/if($FREE,1,$V3)}"; CH3="${CH3//_C_/$V3*64}"; CH3="${CH3//_P_/0.5}"
CHORD="$CH1+$CH2+$CH3"
CHORD="${CHORD//_G_/(2.5-1.9*$FREE)}"; CHORD="${CHORD//_A_/0.03*lt($B,79)}"
# sparkle: the chord an octave up obeys the law too (harmonic 2h, struck 2h times), panned wide
SP1="${PL//_H_/2*$V1}"; SP1="${SP1//_C_/$V1*128}"; SP1="${SP1//_P_/0.05}"
SP2="${PL//_H_/2*$V3}"; SP2="${SP2//_C_/$V3*128}"; SP2="${SP2//_P_/0.95}"
SPK="$SP1+$SP2"; SPK="${SPK//_G_/3}"; SPK="${SPK//_A_/0.014*$GO}"
# lead (bars 56-71): melody of harmonics read from two digit tables, two digits per bar.
# each note flutters at its own harmonic number per bar: the higher it sings, the faster it trembles
LI="($B-56)"
LH="mod(floor(if(lt($LI,8),2128273024202024,3228242730243032)/pow(100,mod($LI,8))),100)"
LEAD="${TONE//_H_/$LH}"; LEAD="${LEAD//_C_/$LH*64}"; LEAD="${LEAD//_P_/0.5}"; LEAD="${LEAD//_G_/3}"; LEAD="${LEAD//_A_/0.024*between($B,56,71)}"
UPPER="$CHORD+$SPK+$LEAD"
# pad: the NEXT chord, comb 1, phase +atan = a pluck played backwards, swelling into the barline;
# the right ear sits one row (0.43 Hz) higher than the left
N1="(8+2*eq($NXT,1)+4*eq($NXT,2)+2*eq($NXT,3))"
N2="(10+2*eq($NXT,1)+5*eq($NXT,2)+4*eq($NXT,3))"
N3="(12+3*eq($NXT,1)+6*eq($NXT,2)+6*eq($NXT,3))"
PLR="${PL//-atan/atan}"; PLR="${PLR//_H_/1}"
PAD="${PLR//_C_/($N1*32+1-$LEFT)}+${PLR//_C_/($N2*64+1-$LEFT)}+${PLR//_C_/($N3*64+1-$LEFT)}+${PLR//_C_/($N1*128+1-$LEFT)}"
PAD="${PAD//_P_/0.5}"; PAD="${PAD//_G_/0.45}"; PAD="${PAD//_A_/0.026*between($B,4,74)}"
BASS="${TONE//_H_/(4+$C)}"; BASS="${BASS//_C_/(4+$C)*32}"; BASS="${BASS//_P_/0.5}"; BASS="${BASS//_G_/1.2}"; BASS="${BASS//_A_/0.07*$GB}"
MAG="st(8,0);st(9,0);_V_;st(7,hypot(ld(8),ld(9)));max(0,255+2.125*8.6859*log(ld(7)+1e-9))"
PHA="st(8,0);st(9,0);_V_;255*mod(atan2(ld(9),ld(8))/(2*PI)+0.5,1)"
SS="spectrumsynth=sample_rate=28160:slide=fullframe:scale=log:win_func=rect:overlap=0"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x65536:d=1:r=1,format=gray,split[c0][c1];
[c0]geq=lum='${MAG//_V_/$UPPER}',split=4[u0][u1][u2][u3];[u0]crop=20:65536:0:0,uspp=quality=2:qp=2:codec=snow[v0];[u1]crop=20:65536:20:0,uspp=quality=2:qp=12:codec=snow[v1];[u2]crop=20:65536:40:0,uspp=quality=2:qp=24:codec=snow[v2];[u3]crop=20:65536:60:0,uspp=quality=2:qp=40:codec=snow[v3];[v0][v1][v2][v3]hstack=4[cm];[c1]geq=lum='${PHA//_V_/$UPPER}'[cp];
[cm][cp]${SS}:channels=2,aresample=48000[chord];
color=c=black:s=${W}x65536:d=1:r=1,format=gray,split[q0][q1];
[q0]geq=lum='${MAG//_V_/$PAD}'[qm];[q1]geq=lum='${PHA//_V_/$PAD}'[qp];
[qm][qp]${SS}:channels=2,aresample=48000[pad];
color=c=black:s=${W}x65536:d=1:r=1,format=gray,split[b0][b1];
[b0]geq=lum='${MAG//_V_/$BASS}'[bm];[b1]geq=lum='${PHA//_V_/$BASS}'[bp];
[bm][bp]${SS}:channels=2,aresample=48000[bass];
color=c=black:s=${W}x32768:d=1:r=1,format=gray,split[k0][k1];
[k0]geq=lum='eq(mod($K,4),0)*$GK*max(0,255+2.125*(-30-8.7*pow(($K*0.4297-52)/28,2)))'[km];
[k1]geq=lum='255*mod(-2.2*log($K*0.4297+1),1)'[kp];
[km][kp]${SS}:channels=1,aresample=48000[kick];
color=c=black:s=${W}x32768:d=1:r=1,format=gray,split[s0][s1];
[s0]geq=lum='eq(mod($K,2),0)*$GS*between($K,400,16000)*max(0,255+2.125*(-56-9*pow(log($K*0.4297/900)/log(2),2)/4))'[sm];
[s1]geq=lum='255*mod(-$K/4-0.005*$K+0.6*(sin($K/57)+sin($K/91+2))+0.22*mod(sin($K*12.9898)*43758.5453,1),1)'[sp];
[sm][sp]${SS}:channels=1,aresample=48000[snare];
color=c=black:s=${W}x32768:d=1:r=1,format=gray,split[h0][h1];
[h0]geq=lum='eq(mod($K,8),0)*$GH*gt($K,15000)*max(0,255+2.125*(-61))'[hm];
[h1]geq=lum='255*mod(-$K/16+eq(mod($B,4),3)*0.35*sin($K/31),1)'[hp];
[hm][hp]${SS}:channels=1,aresample=48000[hats];
[kick]pan=stereo|c0=c0|c1=c0[k2];[snare]pan=stereo|c0=0.9*c0|c1=c0[s2];[hats]pan=stereo|c0=0.6*c0|c1=c0[h2];
[chord]asplit[cd][cw];
aevalsrc=d=3:s=48000:exprs='(random(0)*2-1)*exp(-t*2)|(random(1)*2-1)*exp(-t*2)',lowpass=f=6000[ir];
[cw]highpass=f=200[cw1];[cw1][ir]afir=dry=0:wet=1[rev];
[cd][rev][pad][bass][k2][s2][h2]amix=inputs=7:weights=1 0.3 1 1 1 1 1:normalize=0,
alimiter=limit=0.89:level=0,afade=t=out:st=180:d=6" "$@"
