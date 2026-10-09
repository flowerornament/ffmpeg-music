#!/bin/sh
# 502 — Overtone Lessons
# A teacher plays a song (melody, bass, kick, hats in A aeolian, 100 bpm, Am F C G). You
# never hear the teacher. You hear three students: adaptive filters (anlms, out_mode=e,
# which outputs the filter's ESTIMATE) whose only input is a band-limited impulse train —
# a drone with flat harmonics (closed-form Dirichlet kernel, no aliasing). An LTI filter fed
# a periodic signal can only output that signal's harmonics, so each student can sing the
# song only by lighting up harmonics of its drone: a learned khoomei. A tempered C is
# answered by the 19th harmonic of 55 Hz, a B by the 9th. Melody becomes overtone melody.
#   left  : drone A1 (55 Hz, 170 harmonics)            — the fixed room
#   right : drone on the bar's root, just-tuned (A 1, F 4/5, C 6/5, G 8/9), 180 harmonics  — the moving room
#   centre: drone A0 (27.5 Hz) learning only the bass and kick, with a high mu so it
#           overfits the drums and passes their thump — the body
# FORM = LEARNING RATE (mu, sent as commands). mu is how much the filter believes the world
# over its prior: tiny mu -> the drone's harmonic lattice wins; big mu -> the teacher's own
# tempered notes leak through and grind against the just partials.
#   0'00 ignorance (mu .0007, slow bloom) · 0'30 lessons (.004) · 0'54 fluency (.015)
#   1'18 overfitting (.06 -> .15, the teacher bleeds in) · 2'00 teacher falls silent; the
#   students stop learning (mu .00003) and keep singing what they last knew, while
#   the moving drone carries that frozen memory onto new roots.
BLIT='st(1,sin(PI*ld(0)));if(lt(abs(ld(1)),1e-6),1,(sin((2*K+1)*PI*ld(0))/ld(1)-1)/(2*K))*0.5'
B55="st(0,mod(ld(0)+55/48000,1));$(echo "$BLIT" | sed 's/K/170/g')"
B27="st(0,mod(ld(0)+27.5/48000,1));$(echo "$BLIT" | sed 's/K/44/g')"
BROOT="st(2,mod(floor(t/2.4),4));st(3,55*if(eq(ld(2),0),1,if(eq(ld(2),1),0.8,if(eq(ld(2),2),1.2,8/9))));st(0,mod(ld(0)+ld(3)/48000,1));$(echo "$BLIT" | sed 's/K/180/g')"
# teacher. step s (eighths, 0.3 s), tau = time since step, q = bar within 4-bar phrase.
# melody tables are read right-to-left, digit 9 = rest; degree d -> semitone in aeolian.
TEACH="st(2,floor(t/0.3));st(9,t-ld(2)*0.3);st(6,mod(floor(ld(2)/8),4));st(7,mod(floor(ld(2)/32),2));
st(3,mod(floor(if(eq(ld(7),0),if(eq(ld(6),0),59754949,if(eq(ld(6),1),90912492,if(eq(ld(6),2),79754949,99124592))),if(eq(ld(6),0),59754949,if(eq(ld(6),1),97895792,if(eq(ld(6),2),24954979,99924542))))/pow(10,mod(ld(2),8))),10));
st(4,220*pow(2,(floor((12*(ld(3)+5)+5)/7)-9)/12));st(5,mod(ld(5)+ld(4)/48000,1));
st(1,mod(floor(6250/pow(10,ld(6))),10));st(8,mod(ld(8)+55*pow(2,(floor((12*(ld(1)+5)+5)/7)-9)/12)/48000,1));
lt(t,120)*(lt(ld(3),9)*0.22*(2*ld(5)-1)*exp(-ld(9)*1.5)
 +0.28*(2*ld(8)-1)*(0.4+0.6*exp(-ld(9)*6))
 +eq(mod(ld(2),2),0)*0.7*sin(2*PI*(45+110*exp(-ld(9)*30))*ld(9))*exp(-ld(9)*7)
 +eq(mod(ld(2),2),1)*0.3*(random(0)*2-1)*exp(-ld(9)*40))"
MU="0 anlms@l mu 0.0007, anlms@r mu 0.0007;30 anlms@l mu 0.004, anlms@r mu 0.004;54 anlms@l mu 0.015, anlms@r mu 0.015;78 anlms@l mu 0.06, anlms@r mu 0.06;100 anlms@l mu 0.15, anlms@r mu 0.15;120 anlms@l mu 0.00003, anlms@r mu 0.00003, anlms@s mu 0.02"
ROOM="st(4,0);st(0,0);while(lt(ld(0),9),st(1,0);while(lt(ld(1),7),st(2,0);while(lt(ld(2),6),st(3,sqrt(pow(ld(0)*55,2)+pow(ld(1)*68.75,2)+pow(ld(2)*82.5,2)));st(4,ld(4)+pow(0.4,gt(ld(0),0)+gt(ld(1),0)+gt(ld(2),0))*cos(ld(0)*PX)*cos(ld(1)*PY)*cos(ld(2)*PZ)*exp(-t*(2+ld(3)/200))*sin(2*PI*ld(3)*t));st(2,ld(2)+1));st(1,ld(1)+1));st(0,ld(0)+1));0.05*ld(4)"
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=168:exprs='$TEACH',asendcmd=c='$MU',asplit=3[d1][d2][d3];
aevalsrc=s=48000:d=168:exprs='$B55'[x1];
aevalsrc=s=48000:d=168:exprs='$BROOT'[x2];
aevalsrc=s=48000:d=168:exprs='$B27'[x3];
[x1][d1]anlms@l=order=1100:mu=0.0007:out_mode=e[L];
[x2][d2]anlms@r=order=1100:mu=0.0007:out_mode=e[R];
[d3]lowpass=f=160[d3l];[x3][d3l]anlms@s=order=1800:mu=0.25:out_mode=e,lowpass=f=300[S];
[L][R]amerge,pan=stereo|c0=c0|c1=c1,asplit[LR][w0];[S]pan=stereo|c0=c0|c1=c0[SS];
aevalsrc=s=8000:d=2.5:exprs='$(echo "$ROOM" | sed 's/PX/0.31/;s/PY/0.53/;s/PZ/0.17/')|$(echo "$ROOM" | sed 's/PX/0.37/;s/PY/0.47/;s/PZ/0.23/')',aresample=48000[ir];
[w0]highpass=f=200[w1];[w1][ir]afir=irnorm=1:wet=0.5[W];
[LR][SS][W]amix=inputs=3:weights=2.8 0.9 0.6:normalize=0,equalizer=f=2500:t=o:w=2:g=5,
acompressor=threshold=0.25:ratio=2.5:attack=10:release=200,alimiter=level=0:limit=0.89,afade=t=in:d=2,afade=t=out:st=140:d=28" "$@"
