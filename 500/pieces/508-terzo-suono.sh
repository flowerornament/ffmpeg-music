#!/bin/sh
# 508 — Terzo Suono
# Tartini tuned his double stops by listening for the "third sound": the difference tone
# two notes make below themselves. axcorrelate (a measurement filter: normalized windowed
# cross-correlation of two streams) computes it. Correlating a sine at f1 with one at f2
# over a short window outputs, mostly, a sine at f2-f1 (and a weaker f1+f2) — at full
# scale, whatever the input level.
# A duet of two pure voices, one per ear, plays PAIRS OF HARMONICS of a bass note that
# nobody plays: (n·b, m·b). Their third sound is (m-n)·b — the absent bass, or its octave,
# or its twelfth — and their sum tone (n+m)·b is another harmonic of it, so everything the
# correlator makes is in tune. The pair table is the composition: it decides the duet's
# register AND the bass's harmonic (pairs 4:5 5:6 -> b, 6:8 4:6 3:5 -> 2b, 5:8 6:9 -> 3b).
# Bass notes (just, per bar): A 55, F 44, C 66, G 49.5 ... 96 bpm, eighths.
# Form: the duet alone; the third sound fades in under it and walks; the pairs widen and
# the bass climbs its harmonics; at the end the duet fades away and — because correlation
# is normalized — the third sound does not: the ghost outlives the two voices that made it
# (they fade to -54 dB, not to zero: below ~1e-15 of signal energy axcorrelate gives up).
E=0.3125     # eighth note
# clock: bar, eighth-in-bar, time-in-eighth, 4-bar unit s, section group g
BAR="st(0,floor(t/(8*$E)));st(1,mod(floor(t/$E),8));st(2,t-floor(t/$E)*$E);st(5,floor(t/(32*$E)));
st(8,if(lt(ld(5),5),0,if(lt(ld(5),9),1,if(lt(ld(5),13),2,3))));
st(9,mod(ld(0)+ld(8),4));st(3,55*if(eq(ld(9),0),1,if(eq(ld(9),1),0.8,if(eq(ld(9),2),1.2,0.9))));
st(6,mod(floor(if(eq(ld(8),0),54536454,if(eq(ld(8),1),54653654,if(eq(ld(8),2),95869586,75647564)))/pow(10,ld(1))),10));
st(7,ld(6)+mod(floor(if(eq(ld(8),0),11122111,if(eq(ld(8),1),21332232,if(eq(ld(8),2),24332433,12131213)))/pow(10,ld(1))),10))"
# lower voice: harmonic n of the absent bass b; upper voice: harmonic m = n + k.
# groups: g0 (0'00) k mostly 1 -> third sound = b; g1 (0'50) k 1..3; g2 (1'30) n up to 9,
# k 2..4, the bass climbs its harmonics; g3 (2'10) k 1..3 again, progression rotated each group.
# each voice has 4 harmonics; every partial of both is a multiple of b, so every difference
# and sum the correlator makes is a harmonic of b too.
H(){ echo "(sin(2*PI*$1*ld(3)*t)+sin(4*PI*$1*ld(3)*t)/2+sin(6*PI*$1*ld(3)*t)/3+sin(8*PI*$1*ld(3)*t)/4)"; }
VL="$BAR;0.22*$(H 'ld(6)')*(0.6+0.4*exp(-ld(2)*6))"
VU="$BAR;0.22*$(H 'ld(7)')*(0.6+0.4*exp(-ld(2)*6))"
ENV="$BAR;(0.35+0.65*exp(-ld(2)*5))*min(1,max(0,(t-20)/10))"
ROOM="st(4,0);st(0,1);while(lt(ld(0),40),st(3,ld(0)*110);st(4,ld(4)+cos(PI*ld(0)*PX)*exp(-t*(2+ld(3)/500))*sin(2*PI*ld(3)*t));st(3,ld(0)*137.5);st(4,ld(4)+cos(PI*ld(0)*PY)*exp(-t*(2+ld(3)/500))*sin(2*PI*ld(3)*t));st(3,ld(0)*165);st(4,ld(4)+cos(PI*ld(0)*PZ)*exp(-t*(2+ld(3)/500))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));0.02*ld(4)"
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=184:exprs='$VL'[l];
aevalsrc=s=48000:d=184:exprs='$VU'[u];
[l]volume='max(0.002,min(1,(160-t)/20))':eval=frame:precision=double,asplit[l1][l2];
[u]volume='max(0.002,min(1,(160-t)/20))':eval=frame:precision=double,asplit[u1][u2];
[l1][u1]axcorrelate=size=96:algo=fast,asplit[c0][c1];
aevalsrc=s=48000:d=184:exprs='$ENV'[env];
[c0][env]amultiply,lowpass=f=900,pan=stereo|c0=c0|c1=c0[third];
[c1]highpass=f=600,volume=0.12,pan=stereo|c0=c0|c1=c0[sum];
[l2][u2]amerge,pan=stereo|c0=c0|c1=c1,asplit[duet][dw];
aevalsrc=s=16000:d=2.5:exprs='$(echo "$ROOM" | sed 's/PX/0.31/;s/PY/0.53/;s/PZ/0.17/')|$(echo "$ROOM" | sed 's/PX/0.37/;s/PY/0.47/;s/PZ/0.23/')',aresample=48000[ir];
[dw][ir]afir=irnorm=2:irgain=0.4[dr];
[duet][dr][third][sum]amix=inputs=4:weights=0.8 0.5 0.55 1:normalize=0,volume=0.55,
acompressor=threshold=0.4:ratio=2:attack=15:release=250,alimiter=level=0:limit=0.85,afade=t=in:d=2,afade=t=out:st=172:d=12" "$@"
