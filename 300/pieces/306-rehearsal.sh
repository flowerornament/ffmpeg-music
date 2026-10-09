#!/bin/sh
# 306 — Rehearsal (PHI No. 6)
# A machine learns to cadence while you listen, and its chords are drawn into the spectrum.
#  the learner  one aevalsrc expression with memory. Every 1.5 s it picks the next chord root
#               (scale degree r) from three moves — down a fifth, down a third, up a step —
#               by softmax over  reward + 0.8 * V[next]. V holds a learned value per degree,
#               seven 7-bit numbers packed into ONE register (st(2), base 128). Reward is 1 only
#               for V -> I (0.6 for vii -> I), minus 0.05 per chord. Temporal-difference learning
#               (V[r] += 0.3 (R + 0.8 V[r'] - V[r])) pushes value backwards from the cadence:
#               first the dominant learns it is near home, then ii and IV, then vi, then iii.
#               The temperature anneals 2 -> 0.02: it starts by wandering, and ends by having
#               found its way home.
#  the pen      the same expression draws the chord. `showwaves` plots one dot per sample, so
#               the 32 samples of each image column are 32 dots: four voices x six harmonics
#               plus the bass, and the root at /2 and /4 where those land on a bin (subs). Voices fold into fixed windows (smooth voice leading). The
#               scale is just: degrees -> bins 24 27 30 32 36 40 45 (harmonics of 11.72 Hz),
#               so ii is the sour 27:32:40 triad, as in any true just intonation.
#  the eye      one picture per chord, shown twice (arrive, and 1 s later depart: interleave); minterpolate (optical flow) carries the partials
#               between them; peak-pick; resynthesize (as in 301; left ear esa, right ear tss8).
#  pulse        the rhythmicon (row b pulses b times per 16 s) fades in as the learner commits.
S=72000
DEG="mod(floor(24273032364045/pow(100,6-mod(ld(5),7))),100)*pow(2,floor(ld(5)/7))"
FOLD="ld(6)*pow(2,max(0,ceil(log(ld(7)/ld(6))/log(2)-0.000001)))"
LEARN="st(5,2*pow(0.08,clip(t/170,0,1)));
st(6,exp((eq(ld(1),4)+0.8*mod(floor(ld(2)/pow(128,mod(ld(1)+3,7))),128)/127)/ld(5)));
st(7,exp((0.8*mod(floor(ld(2)/pow(128,mod(ld(1)+5,7))),128)/127)/ld(5)));
st(8,exp((0.6*eq(ld(1),6)+0.8*mod(floor(ld(2)/pow(128,mod(ld(1)+1,7))),128)/127)/ld(5)));
st(9,mod(sin(floor(n/$S)*12.9898+4.1)*43758.5453,1)*(ld(6)+ld(7)+ld(8)));
st(9,mod(ld(1)+if(lt(ld(9),ld(6)),3,if(lt(ld(9),ld(6)+ld(7)),5,1)),7));
st(6,mod(floor(ld(2)/pow(128,ld(1))),128));
st(7,eq(ld(9),0)*(eq(ld(1),4)+0.6*eq(ld(1),6))-0.05+0.8*mod(floor(ld(2)/pow(128,ld(9))),128)/127);
st(8,round(127*clip(ld(6)/127+0.15*(ld(7)-ld(6)/127),0,1)));
st(2,ld(2)+(ld(8)-ld(6))*pow(128,ld(1)));
st(1,ld(9))"
DRAW="st(0,mod(n,32));
st(5,ld(1)+if(lt(ld(0),6),0,if(lt(ld(0),12),2,if(lt(ld(0),18),4,if(lt(ld(0),24),7,0)))));
st(6,$DEG);
st(7,if(lt(ld(0),6),36,if(lt(ld(0),12),48,if(lt(ld(0),18),60,if(lt(ld(0),24),80,24)))));
st(6,if(lt(ld(0),30),$FOLD,if(eq(ld(0),30),if(mod(ld(6),2),ld(6),ld(6)/2),if(mod(ld(6),4),if(mod(ld(6),2),ld(6),ld(6)/2),ld(6)/4))));
st(8,if(lt(ld(0),24),mod(ld(0),6)+1,if(lt(ld(0),30),ld(0)-23,1)));
-1+(ld(6)*ld(8)+1.5)/1024"
PICK="p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*0.11*pow(max(H-1-Y,1)/24,-0.6)*(1+st(9,clip((T-50)/40,0,1)*clip((176-T)/10,0,1))*(1.8*exp(-5*mod((H-1-Y)*T/16,1))-1))"
PHASE="255*mod((H-1-Y)*N/4+sin((H-1-Y)*12.9898)*43758.5453,1)"
SYN="spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75,aformat=channel_layouts=mono"
F=46.875
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=186:exprs='if(eq(n,0),st(1,0)+st(2,0),0);if(eq(mod(n,$S),0)*gt(n,0),$LEARN,0);$DRAW',
 showwaves=s=32x2048:mode=point:n=2250:colors=white:draw=full,format=gray,pad=32:2049:0:1,
 gblur=sigma=0.01:sigmaV=1.0,geq=lum='min(255,4*p(X,Y))',settb=1/1000,setpts='(N-1)*1.5/TB',select='gte(n,1)',split[ka][kb];
 [kb]setpts='PTS+1.0/TB'[kc];[ka][kc]interleave,split[k1][k2];
[k1]minterpolate=fps=$F:mi_mode=mci:scd=none:me_mode=bidir:me=esa:search_param=32,format=gray,crop=1:2049:16:0,geq=lum='$PICK'[mL];
[k2]minterpolate=fps=$F:mi_mode=mci:scd=none:me_mode=bilat:me=tss:mb_size=8,format=gray,crop=1:2049:16:0,geq=lum='$PICK'[mR];
color=c=black:s=1x2049:r=$F:d=190,format=gray,geq=lum='$PHASE',split[pL][pR];
[mL][pL]$SYN[l];[mR][pR]$SYN[r];
[l][r]join=inputs=2:channel_layout=stereo,atrim=0:180,asplit[dry][w];
aevalsrc=d=4:s=48000:exprs='(random(0)*2-1)*exp(-t*1.4)|(random(1)*2-1)*exp(-t*1.4)',lowpass=f=6000[ir];
[w]highpass=f=150[w2];[w2][ir]afir=dry=1:wet=1[wet];
[dry][wet]amix=inputs=2:weights=1 0.25:normalize=0,highpass=f=25,
 acompressor=threshold=0.2:ratio=2.5:attack=20:release=300,volume=1.5,alimiter=limit=0.89:level=0,
 afade=t=in:d=3,afade=t=out:st=172:d=8
" "$@"
