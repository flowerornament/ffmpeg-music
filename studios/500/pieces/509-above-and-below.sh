#!/bin/sh
# 509 — Above and Below
# A duet you never hear. Two voices, one per channel, play pairs of harmonics (n·b, m·b) of a
# bass note b that nobody plays (each voice has 12 harmonics). Two listening machines report
# on them, and only their reports reach you:
#   ABOVE — the surround upmixer's centre channel: the partials the voices share, i.e. the
#           multiples of lcm(n,m)·b. A 4:5 pair over A 55 sings C#6 (1100 Hz), 5:6 sings
#           E6+ (1650), 2:3 sings E5 (330·k)... a high melody of common overtones.
#   BELOW — axcorrelate: the difference tone (m-n)·b at full scale. The absent bass itself.
# The middle of the spectrum, where the music actually is, is left empty: a piece with a
# hole where the duet should be — only Helmholtz's coincidences above it and Tartini's
# third sound below it. Bass progression (just): A 55, F 44, C 66, E 41.25; 104 bpm eighths;
# pair tables per 4-bar group. A trace of each voice's private partials (the upmixer's front
# channels) leaks in very quietly, like the duet heard through a wall.
E=0.2885
CLK="st(0,floor(t/(8*$E)));st(1,mod(floor(t/$E),8));st(2,t-floor(t/$E)*$E);st(5,floor(t/(32*$E)));
st(8,mod(ld(5),4));st(9,mod(ld(0),4));st(3,55*if(eq(ld(9),0),1,if(eq(ld(9),1),0.8,if(eq(ld(9),2),1.2,0.75))));
st(6,mod(floor(if(eq(ld(8),0),43424543,if(eq(ld(8),1),53235432,if(eq(ld(8),2),24352435,34543453)))/pow(10,ld(1))),10));
st(7,ld(6)+mod(floor(if(eq(ld(8),0),11111111,if(eq(ld(8),1),12121213,if(eq(ld(8),2),11231123,21312131)))/pow(10,ld(1))),10))"
# voice with 12 harmonics, amplitude 1/h, partials locked to global time (equal f = equal phase)
V(){ echo "$CLK;st(4,0);st(9,1);while(lt(ld(9),13),st(4,ld(4)+sin(2*PI*ld(9)*ld($1)*ld(3)*t)/ld(9));st(9,ld(9)+1));0.12*ld(4)*(0.55+0.45*exp(-ld(2)*7))"; }
ENV="$CLK;(0.3+0.7*exp(-ld(2)*6))"
ROOM="st(4,0);st(0,1);while(lt(ld(0),60),st(3,ld(0)*110);st(4,ld(4)+cos(PI*ld(0)*PX)*exp(-t*(1.5+ld(3)/900))*sin(2*PI*ld(3)*t));st(3,ld(0)*137.5);st(4,ld(4)+cos(PI*ld(0)*PY)*exp(-t*(1.5+ld(3)/900))*sin(2*PI*ld(3)*t));st(3,ld(0)*165);st(4,ld(4)+cos(PI*ld(0)*PZ)*exp(-t*(1.5+ld(3)/900))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));0.02*ld(4)"
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=150:exprs='$(V 6)'[lo];
aevalsrc=s=48000:d=150:exprs='$(V 7)'[hi];
[lo]asplit[l1][l2];[hi]asplit[h1][h2];
[l1][h1]amerge,pan=stereo|c0=c0|c1=c1,surround=chl_out=5.1,asplit[s1][s2];
[s1]pan=mono|c0=c2,highpass=f=500,asplit[top][tw];
aevalsrc=s=24000:d=3:exprs='$(echo "$ROOM" | sed 's/PX/0.31/;s/PY/0.53/;s/PZ/0.17/')|$(echo "$ROOM" | sed 's/PX/0.37/;s/PY/0.47/;s/PZ/0.23/')',aresample=48000[ir];
[tw]pan=stereo|c0=c0|c1=c0[tw2];[tw2][ir]afir=irnorm=2:irgain=0.5[topr];
[top]pan=stereo|c0=c0|c1=c0,adecorrelate=stages=10:seed=9[topd];
[s2]pan=stereo|c0=c0|c1=c1,volume=0.06[wall];
[l2][h2]axcorrelate=size=128:algo=slow,lowpass=f=320,lowpass=f=320[cor];
aevalsrc=s=48000:d=150:exprs='$ENV'[env];
[cor][env]amultiply,pan=stereo|c0=c0|c1=c0[below];
[topd][topr][below][wall]amix=inputs=4:weights=2 1.6 0.32 0.6:normalize=0,
acompressor=threshold=0.4:ratio=2:attack=10:release=200,alimiter=level=0:limit=0.85,afade=t=in:d=1,afade=t=out:st=140:d=10" "$@"
