#!/bin/sh
# 103 — Every Note Once                                  (studio 100 · RASTRUM)
#
# Magnitude is the mode; phase is the melody.
# The raster: sample_rate 26729, FFT 65536 -> row k = k * 0.40785 Hz, one column = one bar of
# 2.452 s (97.9 bpm), rect window, no overlap. Sixteen notes of D dorian in just intonation
# (rows 360*{1,9/8,6/5,4/3,3/2,5/3,9/5}*2^oct, D3 = row 360 = 146.8 Hz) are drawn as sixteen
# Lorentzian clusters: each is a pluck struck ONCE per bar. The magnitude image therefore
# hardly changes for the whole piece. When each note sounds is set only by the slope of its
# phase: note n is delayed to sixteenth slot (a*n + c) mod 16. With a odd that is a
# permutation, so every bar plays every note of the mode exactly once; a picks the order:
#   a=1 scale up · a=15 scale down · a=9 two interleaved voices (compound melody) ·
#   a=3 / a=11 / a=5 / a=13 leaping figures · c rotates the figure (phasing).
# The right ear hears the same row half a bar later (c+8): a canon made of phase.
# Sections change the note set (the magnitude, i.e. the harmony) far more slowly:
#   0-15 scale steps on D · 16-31 stacked thirds D2..G5 · 32-47 scale steps on G ·
#   48-63 thirds on D, c turning one slot per bar · 64-71 the top notes leave, two per bar.
W=72
SR=26729
K="(32767-mod(Y,32768))"
LEFT="gte(Y,32768)"
B="X"
R="(360+120*between($B,32,47))"
S3="(between($B,16,31)+between($B,48,63))"
A="(2*mod(floor(4470551144447700/pow(10,mod($B,16))),10)+1)"
CC="(if(between($B,48,63),$B,0)+8*(1-$LEFT)*gte(_N_,8))"
RAT="(1+0.125*eq(ld(6),1)+0.2*eq(ld(6),2)+0.33333333*eq(ld(6),3)+0.5*eq(ld(6),4)+0.66666667*eq(ld(6),5)+0.8*eq(ld(6),6))"
ON="lt(_N_,min(4*($B+1),16-2*max(0,$B-63)))"
# (av_expr refuses flat chains of ~99 ';' -- each note is parenthesized)
# degree of note n -> row; then the pluck at that row (and its octave) delayed to its slot
NOTE="st(6,_N_+$S3*(_N_-7)+70);st(7,floor(ld(6)/7)-10);st(6,mod(ld(6),7));st(4,round($R*pow(2,ld(7))*$RAT));st(5,mod($A*_N_+$CC,16)/16);st(0,0.017*$ON);
if(lt(abs($K-ld(4)),45),st(1,($K-ld(4))/1.4);st(2,ld(0)/sqrt(1+ld(1)*ld(1)));st(3,-atan(ld(1))-2*PI*$K*ld(5));st(8,ld(8)+ld(2)*cos(ld(3)));st(9,ld(9)+ld(2)*sin(ld(3))),0);
if(lt(abs($K-2*ld(4)),90),st(1,($K-2*ld(4))/3.2);st(2,0.35*ld(0)/sqrt(1+ld(1)*ld(1)));st(3,-atan(ld(1))-2*PI*$K*ld(5));st(8,ld(8)+ld(2)*cos(ld(3)));st(9,ld(9)+ld(2)*sin(ld(3))),0);
if(lt(abs($K-3*ld(4)),120),st(1,($K-3*ld(4))/5);st(2,0.12*ld(0)/sqrt(1+ld(1)*ld(1)));st(3,-atan(ld(1))-2*PI*$K*ld(5));st(8,ld(8)+ld(2)*cos(ld(3)));st(9,ld(9)+ld(2)*sin(ld(3))),0)"
ROW="(${NOTE//_N_/0});(${NOTE//_N_/1});(${NOTE//_N_/2});(${NOTE//_N_/3});(${NOTE//_N_/4});(${NOTE//_N_/5});(${NOTE//_N_/6});(${NOTE//_N_/7});
(${NOTE//_N_/8});(${NOTE//_N_/9});(${NOTE//_N_/10});(${NOTE//_N_/11});(${NOTE//_N_/12});(${NOTE//_N_/13});(${NOTE//_N_/14});(${NOTE//_N_/15})"
# drone: root and fifth an octave below, struck once per bar, right ear one row higher
DRONE="st(4,$R/2+1-$LEFT);if(lt(abs($K-ld(4)),20),st(1,($K-ld(4))/0.3);st(2,0.05*lt($B,70)/sqrt(1+ld(1)*ld(1)));st(3,-atan(ld(1)));st(8,ld(8)+ld(2)*cos(ld(3)));st(9,ld(9)+ld(2)*sin(ld(3))),0);
st(4,$R*3/4+1-$LEFT);if(lt(abs($K-ld(4)),20),st(1,($K-ld(4))/0.3);st(2,0.025*between($B,8,69)/sqrt(1+ld(1)*ld(1)));st(3,-atan(ld(1)));st(8,ld(8)+ld(2)*cos(ld(3)));st(9,ld(9)+ld(2)*sin(ld(3))),0)"
MAG="st(8,0);st(9,0);$ROW;($DRONE);max(0,255+2.125*8.6859*log(hypot(ld(8),ld(9))+1e-9))"
PHA="st(8,0);st(9,0);$ROW;($DRONE);255*mod(atan2(ld(9),ld(8))/(2*PI)+0.5,1)"
SS="spectrumsynth=sample_rate=$SR:slide=fullframe:scale=log:win_func=rect:overlap=0"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x65536:d=1:r=1,format=gray,split[a0][a1];
[a0]geq=lum='$MAG'[am];[a1]geq=lum='$PHA'[ap];
[am][ap]$SS:channels=2,aresample=48000,asplit[dry][w0];
color=c=black:s=${W}x32768:d=1:r=1,format=gray,split[k0][k1];
[k0]geq=lum='eq(mod($K,2),0)*between($B,32,63)*max(0,255+2.125*(-30-8.7*pow(($K*0.40785-48)/22,2)))'[km];
[k1]geq=lum='255*mod(-1.8*log($K*0.40785+1),1)'[kp];
[km][kp]$SS:channels=1,aresample=48000,pan=stereo|c0=c0|c1=c0[kick];
color=c=black:s=${W}x32768:d=1:r=1,format=gray,split[h0][h1];
[h0]geq=lum='eq(mod($K,16),0)*between($B,40,63)*gt($K,16000)*(255+2.125*(-63))'[hm];
[h1]geq=lum='255*mod(-$K/32+0.25*sin($K/40)+0.1*mod(sin($K*7.13)*43758.5453,1),1)'[hp];
[hm][hp]$SS:channels=1,aresample=48000,pan=stereo|c0=0.7*c0|c1=c0[hats];
aevalsrc=d=4:s=48000:exprs='(random(0)*2-1)*exp(-t*1.4)|(random(1)*2-1)*exp(-t*1.4)',lowpass=f=5000[ir];
[w0]highpass=f=250[w1];[w1][ir]afir=dry=0:wet=1[rev];
[dry][rev][kick][hats]amix=inputs=4:weights=1 0.3 1 1:normalize=0,volume=0.75,
alimiter=limit=0.79:level=0,afade=t=out:st=170:d=6.5" "$@"
