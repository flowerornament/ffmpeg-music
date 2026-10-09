#!/bin/sh
# 506 — Coincidence
# The surround upmixer (surround=chl_out=5.1) is a repair tool: it guesses which parts of a
# stereo mix belong in the centre speaker by comparing the two channels bin by bin. Give
# it two different voices, one per channel, and the centre gets exactly the partials the
# two voices SHARE — the coincident harmonics that Helmholtz said consonance is made of.
# A just fifth 220/330 puts 660 and 1320 in the centre, a major third 220/275 puts 1100,
# a tritone or a seventh puts almost nothing. The upmixer is a consonance detector, and its
# centre channel sings the lowest common harmonic of whatever the two voices are doing.
# Here the two voices play the same twelve-note pattern in just intonation (A, ratios
# 1 9/8 5/4 4/3 3/2 5/3 15/8 2), plucked (16 harmonics), harmonics locked to global time so equal
# frequencies are equal phases. The right voice phases ahead one step at a time — ten
# seconds locked at each offset, three seconds drifting — so the interval between the
# voices at every step keeps changing, and the centre plays a different "resulting
# pattern" at each offset: the coincidence melody, high and bright, computed, not imagined.
# A soft A1 thump marks each voice's downbeat; it too lands in the centre only when the
# voices are aligned. Mix: centre (coincidences) up front through a small math room; the
# fronts (each voice's private partials) low and wide; LFE and backs underneath.
# Offsets 0..12: in unison (all centre) -> apart -> back to unison after a full cycle.
ST=0.14            # seconds per note
H="st(9,0);st(8,1);while(lt(ld(8),17),st(9,ld(9)+sin(2*PI*ld(8)*ld(4)*t)/pow(ld(8),0.9));st(8,ld(8)+1))"
# position -> step s, time-in-note u, ratio r, freq; ld(7) holds the position in steps
V="st(2,floor(ld(7)));st(3,(ld(7)-ld(2))*$ST);st(5,mod(ld(2),12));
st(6,mod(floor(if(lt(ld(5),6),720524,236401)/pow(10,mod(ld(5),6))),10));
st(4,220*if(eq(ld(6),0),1,if(eq(ld(6),1),9/8,if(eq(ld(6),2),5/4,if(eq(ld(6),3),4/3,if(eq(ld(6),4),3/2,if(eq(ld(6),5),5/3,if(eq(ld(6),6),15/8,2))))))));
$H;0.09*ld(9)*exp(-ld(3)*7)*(1-exp(-ld(3)*900))+eq(ld(5),0)*0.5*sin(2*PI*55*t)*exp(-ld(3)*6)*(1-exp(-ld(3)*300))"
# right voice offset: plateau 10 s at each integer, 3 s smoothstep to the next; 8 s intro
OFF="st(0,max(0,t-8)/13);st(1,floor(ld(0)));st(0,min(1,max(0,(ld(0)-ld(1))*13-10)/3));min(12,ld(1)+ld(0)*ld(0)*(3-2*ld(0)))"
ROOM="st(4,0);st(0,1);while(lt(ld(0),40),st(3,ld(0)*110);st(4,ld(4)+cos(PI*ld(0)*PX)*exp(-t*(3+ld(3)/600))*sin(2*PI*ld(3)*t));st(3,ld(0)*137.5);st(4,ld(4)+cos(PI*ld(0)*PY)*exp(-t*(3+ld(3)/600))*sin(2*PI*ld(3)*t));st(3,ld(0)*165);st(4,ld(4)+cos(PI*ld(0)*PZ)*exp(-t*(3+ld(3)/600))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));0.02*ld(4)"
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=176:c=stereo:exprs='st(7,t/$ST);$V|st(7,t/$ST+($OFF));$V',
surround=chl_out=5.1:lfe_low=120,asplit[sa][sb];
[sa]pan=stereo|c0=c2|c1=c2,asplit[cd][cw];
aevalsrc=s=16000:d=2:exprs='$(echo "$ROOM" | sed 's/PX/0.31/;s/PY/0.53/;s/PZ/0.17/')|$(echo "$ROOM" | sed 's/PX/0.37/;s/PY/0.47/;s/PZ/0.23/')',aresample=48000[ir];
[cw][ir]afir=irnorm=2:irgain=0.5[cr];
[sb]pan=stereo|c0=0.35*c0+0.7*c3+0.3*c4|c1=0.35*c1+0.7*c3+0.3*c5,stereotools=slev=1.6[rest];
[cd][cr][rest]amix=inputs=3:weights=2.6 1.6 0.7:normalize=0,volume=1.3,
acompressor=threshold=0.35:ratio=2:attack=10:release=200,alimiter=level=0:limit=0.8,afade=t=in:d=1,afade=t=out:st=168:d=8" "$@"
