#!/bin/sh
# 104 — Prolation                                        (studio 100 · RASTRUM)
#
# One drawn score, read at four sample rates at once.
# On the raster the sample rate is both tuning fork and metronome: row k sounds at
# k*S/65536 Hz and a column lasts 65536/S s. So reading the same picture at 1.5x the
# sample rate is the same music a fifth higher AND one and a half times faster; 2x is the
# octave at double speed; 3x the twelfth at triple speed. That is a mensuration canon
# (Ockeghem's Missa prolationum, Nancarrow's tempo canons) in which the tempo ratios are
# the interval ratios: 2:3:4:6 in time, A:E:A:E in pitch. The voices realign every two
# slow bars and all four end together on the cadence (48, 72, 96, 144 columns).
# The score (8 bars x 8 slots, A major pentatonic in just intonation, A2 = row 384):
#   10305043 20010000 10305060 70654000 50403045 60087000 60504020 10000000
#   (digit = scale degree+1, 0 = rest; odd phrases are lifted two degrees)
# plus a bass pluck per bar and a clock comb ticking 8 per bar (12, 16, 24 in the others).
# Each note is a Lorentzian pluck (partials 1, 2, 3 and a glassy 5.4) placed in its slot by
# the slope of its phase. Entries: x1 at 0 s, x1.5 at 28 s, x2 at 56 s, x3 at 84 s.
S=18772
K="(32767-Y)"
J="mod(X,8)"
Q="floor(X/8)"
BAR="if(eq($J,0),10305043,if(eq($J,1),20010000,if(eq($J,2),10305060,if(eq($J,3),70654000,if(eq($J,4),50403045,if(eq($J,5),60087000,if(eq($J,6),60504020,10000000)))))))"
SH="2*mod($Q,2)*lt($J,7)"
PENT="(1+0.125*eq(ld(6),1)+0.25*eq(ld(6),2)+0.5*eq(ld(6),3)+0.66666667*eq(ld(6),4))"
P1="if(lt(abs($K-_M_*ld(4)),_W_),st(1,($K-_M_*ld(4))/_G_);st(2,_A_*ld(0)/sqrt(1+ld(1)*ld(1)));st(3,-atan(ld(1))-2*PI*$K*ld(5));st(8,ld(8)+ld(2)*cos(ld(3)));st(9,ld(9)+ld(2)*sin(ld(3))),0)"
PART="(${P1//_M_/1});(${P1//_M_/2});(${P1//_M_/3});(${P1//_M_/5.4})"
PART="${PART//_W_/40}"; PART="${PART//_G_/1.3}"; PART="${PART//_A_/1}"
NOTE="st(7,mod(floor($BAR/pow(10,7-_S_)),10));if(gt(ld(7),0),st(6,ld(7)-1+$SH);st(3,floor(ld(6)/5));st(6,mod(ld(6),5));st(4,round(384*pow(2,ld(3))*$PENT));st(5,_S_/8);st(0,0.016);$PART,0)"
MEL="(${NOTE//_S_/0});(${NOTE//_S_/1});(${NOTE//_S_/2});(${NOTE//_S_/3});(${NOTE//_S_/4});(${NOTE//_S_/5});(${NOTE//_S_/6});(${NOTE//_S_/7})"
BASS="st(6,mod(floor(442230/pow(10,7-$J)),10));st(4,192*$PENT);st(5,0);st(0,0.035);(${P1//_M_/1});(${P1//_M_/2})"
BASS="${BASS//_W_/30}"; BASS="${BASS//_G_/0.45}"; BASS="${BASS//_A_/1}"
ALL="st(8,0);st(9,0);$MEL;($BASS);if(eq(mod($K,8),0)*between($K,12000,30000),st(8,ld(8)+0.0005),0)"
MAG="$ALL;max(0,255+2.125*8.6859*log(hypot(ld(8),ld(9))+1e-9))"
PHA="$ALL;255*mod(atan2(ld(9),ld(8))/(2*PI)+0.5,1)"
SS="spectrumsynth=slide=fullframe:scale=log:win_func=rect:overlap=0:channels=1"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=144x32768:d=1:r=1,format=gray,split[a0][a1];
[a0]geq=lum='$MAG',split=4[m1][m2][m3][m4];
[a1]geq=lum='$PHA',split=4[p1][p2][p3][p4];
[m1]crop=48:32768:0:0[m1c];[p1]crop=48:32768:0:0[p1c];
[m2]crop=72:32768:0:0[m2c];[p2]crop=72:32768:0:0[p2c];
[m3]crop=96:32768:0:0[m3c];[p3]crop=96:32768:0:0[p3c];
[m1c][p1c]$SS:sample_rate=$S,aresample=48000,aformat=channel_layouts=mono,pan=stereo|c0=c0|c1=c0[v1];
[m2c][p2c]$SS:sample_rate=$((S*3/2)),aresample=48000,aformat=channel_layouts=mono,volume=0.8,volume=0:enable='lt(t,28)',pan=stereo|c0=c0|c1=0.45*c0[v2];
[m3c][p3c]$SS:sample_rate=$((S*2)),aresample=48000,aformat=channel_layouts=mono,volume=0.6,volume=0:enable='lt(t,56)',pan=stereo|c0=0.45*c0|c1=c0[v3];
[m4][p4]$SS:sample_rate=$((S*3)),aresample=48000,aformat=channel_layouts=mono,volume=0.42,volume=0:enable='lt(t,84)',asplit[v4a][v4b];
[v4a][v4b]join=inputs=2:channel_layout=stereo,adelay=0|13[v4];
[v1][v2][v3][v4]amix=inputs=4:normalize=0,asplit[dry][w0];
aevalsrc=d=4:s=48000:exprs='(random(0)*2-1)*exp(-t*1.3)|(random(1)*2-1)*exp(-t*1.3)',lowpass=f=6500[ir];
[w0]highpass=f=200[w1];[w1][ir]afir=dry=0:wet=1[rev];
[dry][rev]amix=inputs=2:weights=1 0.3:normalize=0,volume=0.75,alimiter=limit=0.79:level=0,afade=t=in:d=0.05" "$@"
