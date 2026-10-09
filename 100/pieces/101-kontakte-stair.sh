#!/bin/sh
# 101 — Kontakte Stair                                   (studio 100 · RASTRUM)
#
# A chord falls until it is a rhythm.
# Raster: sample_rate 28160, FFT 65536 -> row k = k*0.4297 Hz; one column = one bar (2.327 s,
# rect window, no overlap). The chord is the harmonic seventh 4:5:6:7. Each chord tone r is a
# comb of rows spaced r*m: a pulse train whose rate is r*m pulses per bar. While m is large
# (m=128 -> 220, 275, 330, 385 Hz: A C# E G-) the pulse trains are pitches; m falls by a
# whole tone per bar (m = 128*2^(-bar/6)), so the chord walks down a whole-tone stair through
# the bass, through the 20 Hz flutter where pitch dissolves, until m=1: four pulses, five,
# six and seven per bar -- the same chord, now a polyrhythm, every voice meeting on the downbeat.
# Each comb keeps a formant at its old pitch, so the ticks still ring with the chord they were.
# Stockhausen's continuum, but on the integer raster the descent is exact all the way down.
#   bars 0-41   the stair (7 octaves)          bars 42-63  m=1, groove: kick = voice 4
#   bars 64-67  m snaps back to 128            right ear = left ear 1/180 bar later
W=68
SR=28160
F=0.4296875
K="(32767-mod(Y,32768))"
LEFT="gte(Y,32768)"
B="X"
M="if(lt($B,42),max(1,round(128*pow(2,-$B/6))),if(lt($B,64),1,128))"
# one pulse voice: comb r*m, -4.5 dB/oct above its own rate, a formant bump at r*128*2 rows
PV="if(eq(mod($K,_R_*ld(1)),0),pow(_R_*ld(1),0.15)*pow($K/(_R_*ld(1)),-0.52)*(1+2.5*exp(-pow(log($K/(_R_*256))/0.35,2)))*lt($K,19000),0)"
MAG="st(1,$M);st(2,(${PV//_R_/4})+(${PV//_R_/5})+(${PV//_R_/6})+0.8*(${PV//_R_/7}));max(0,255+2.125*(8.6859*log(ld(2)+1e-9)-47))"
PHA="255*mod(0.5-$K*(1-$LEFT)/180-1.2*log($K+1),1)"
SS="spectrumsynth=sample_rate=$SR:slide=fullframe:scale=log:win_func=rect:overlap=0"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x65536:d=1:r=1,format=gray,split[a0][a1];
[a0]geq=lum='$MAG'[am];[a1]geq=lum='$PHA'[ap];
[am][ap]$SS:channels=2,aresample=48000,asplit[dry][w0];
color=c=black:s=${W}x32768:d=1:r=1,format=gray,split[k0][k1];
[k0]geq=lum='eq(mod($K,4),0)*between($B,46,63)*max(0,255+2.125*(-29-8.7*pow(($K*$F-50)/26,2)))'[km];
[k1]geq=lum='255*mod(-2.2*log($K*$F+1),1)'[kp];
[km][kp]$SS:channels=1,aresample=48000,pan=stereo|c0=c0|c1=c0[kick];
color=c=black:s=${W}x32768:d=1:r=1,format=gray,split[s0][s1];
[s0]geq=lum='eq(mod($K,2),0)*between($B,50,63)*between($K,400,17000)*max(0,255+2.125*(-56-2.2*pow(log($K*$F/1000)/log(2),2)))'[sm];
[s1]geq=lum='255*mod(-$K/4-0.004*$K+0.6*(sin($K/57)+sin($K/91+2))+0.25*mod(sin($K*12.9898)*43758.5453,1),1)'[sp];
[sm][sp]$SS:channels=1,aresample=48000,pan=stereo|c0=c0|c1=0.85*c0[snare];
aevalsrc=d=3.5:s=48000:exprs='(random(0)*2-1)*exp(-t*1.6)|(random(1)*2-1)*exp(-t*1.6)',lowpass=f=7000[ir];
[w0]highpass=f=300[w1];[w1][ir]afir=dry=0:wet=1[rev];
[dry][rev][kick][snare]amix=inputs=4:weights=1 0.22 1 1:normalize=0,highpass=f=18,volume=1.4,
alimiter=limit=0.79:level=0,afade=t=out:st=152:d=6" "$@"
