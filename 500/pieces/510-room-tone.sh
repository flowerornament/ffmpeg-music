#!/bin/sh
# 510 — Room Tone
# The record's opening: the room, introduced. One rectangular room built from the modal
# formula f(l,m,n) = sqrt((55l)^2 + (68.75m)^2 + (82.5n)^2) — axial fundamentals A, C#, E,
# so its walls are an A major chord — knocked three times, in three places, and left to ring.
#   0'01  the corner      every mode answers: the whole low chord
#   0'15  the wall (x=.5) the root's odd modes cancel: C# and E remain, A thins
#   0'29  the centre      every odd mode cancels: the same chord, an octave higher
#   0'43  all three at once, softly
# Nothing else happens. The same room, three voicings; where you knock is the harmony.
# Two ears at two points of the room are the stereo image. Live damping (1.4 + f/160).
room(){ # sx sy sz  rx ry rz
echo "st(4,0);st(0,1);while(lt(ld(0),30),st(3,ld(0)*55);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$1)*cos(PI*ld(0)*$4)*exp(-t*(1.4+ld(3)/160))*sin(2*PI*ld(3)*t));st(3,ld(0)*68.75);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$2)*cos(PI*ld(0)*$5)*exp(-t*(1.4+ld(3)/160))*sin(2*PI*ld(3)*t));st(3,ld(0)*82.5);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$3)*cos(PI*ld(0)*$6)*exp(-t*(1.4+ld(3)/160))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));st(0,0);while(lt(ld(0),7),st(1,0);while(lt(ld(1),6),st(2,0);while(lt(ld(2),5),st(5,gt(ld(0),0)+gt(ld(1),0)+gt(ld(2),0));st(3,sqrt(pow(ld(0)*55,2)+pow(ld(1)*68.75,2)+pow(ld(2)*82.5,2)));st(4,ld(4)+gte(ld(5),2)*pow(0.45,ld(5)-1)*cos(PI*ld(0)*$1)*cos(PI*ld(1)*$2)*cos(PI*ld(2)*$3)*cos(PI*ld(0)*$4)*cos(PI*ld(1)*$5)*cos(PI*ld(2)*$6)*exp(-t*(1.4+ld(3)/160))*sin(2*PI*ld(3)*t));st(2,ld(2)+1));st(1,ld(1)+1));st(0,ld(0)+1));0.03*ld(4)"
}
EL="0.11 0.07 0.19"; ER="0.17 0.13 0.05"
K="0 0 0"; W="0.5 0 0"; S="0.5 0.5 0.5"
# knock = 5-ms raised-cosine mallet plus a 2-ms slap; channel pairs = corner, wall, centre
KN(){ echo "gte(t,$1)*$2*(lt(t-$1,0.005)*(1-cos(2*PI*(t-$1)/0.005))/2+0.5*(random(9)*2-1)*exp(-abs(t-$1)*700))"; }
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=60:exprs='$(KN 1 1)+$(KN 43 0.35)|$(KN 1 1)+$(KN 43 0.35)|$(KN 15 1)+$(KN 43 0.35)|$(KN 15 1)+$(KN 43 0.35)|$(KN 29 1)+$(KN 43 0.35)|$(KN 29 1)+$(KN 43 0.35)'[x];
aevalsrc=s=4000:d=8:exprs='$(room $K $EL)|$(room $K $ER)|$(room $W $EL)|$(room $W $ER)|$(room $S $EL)|$(room $S $ER)',aresample=48000[ir];
[x][ir]afir=irnorm=-1:irfmt=input:maxir=10,pan=stereo|c0=c0+c2+c4|c1=c1+c3+c5,volume=0.17,
alimiter=level=0:limit=0.85,afade=t=out:st=54:d=6" "$@"
