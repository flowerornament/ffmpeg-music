#!/bin/sh
# Piece No. 1 — "Three Clocks Over an Endless Stair"
# One ffmpeg invocation. No samples, no files in: every sound is an expression.
#  [drone]  Tenney/Risset endless rising Shepard glissando, 9 octave-spaced partials
#           under a gaussian spectral envelope; doubled through afreqshift so the
#           two ears beat against each other (Radigue).
#  [pulse]  Reich phasing: the same Euclidean E(5,8) pattern in both ears, the
#           right ear 1.25% fast, pitches walking harmonics 8..14 of 55 Hz (Partch/Young).
#  [cloud]  Xenakis stochastic grains: hashed per-step random numbers pick FM bells
#           from the harmonic series; density rises from sparse to a swarm.
#  [ir]     The reverb is not a reverb: 4s of decaying noise synthesized in the same
#           graph and convolved with afir.
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=d=150:s=48000:exprs='0.075*clip(t/20,0,1)*clip((150-t)/12,0,1)*(
 exp(-pow(st(1,mod(0+t/20,9))-4.5,2)/3)*sin(1154.16*PI*pow(2,ld(1)))+
 exp(-pow(st(1,mod(1+t/20,9))-4.5,2)/3)*sin(1154.16*PI*pow(2,ld(1)))+
 exp(-pow(st(1,mod(2+t/20,9))-4.5,2)/3)*sin(1154.16*PI*pow(2,ld(1)))+
 exp(-pow(st(1,mod(3+t/20,9))-4.5,2)/3)*sin(1154.16*PI*pow(2,ld(1)))+
 exp(-pow(st(1,mod(4+t/20,9))-4.5,2)/3)*sin(1154.16*PI*pow(2,ld(1)))+
 exp(-pow(st(1,mod(5+t/20,9))-4.5,2)/3)*sin(1154.16*PI*pow(2,ld(1)))+
 exp(-pow(st(1,mod(6+t/20,9))-4.5,2)/3)*sin(1154.16*PI*pow(2,ld(1)))+
 exp(-pow(st(1,mod(7+t/20,9))-4.5,2)/3)*sin(1154.16*PI*pow(2,ld(1)))+
 exp(-pow(st(1,mod(8+t/20,9))-4.5,2)/3)*sin(1154.16*PI*pow(2,ld(1))))',
 lowpass=f=5000,asplit[dl][dr0];
[dr0]afreqshift=shift=0.37[dr];
[dl][dr]amerge=inputs=2,aphaser=in_gain=0.6:out_gain=0.9:delay=4:decay=0.5:speed=0.1[drone];

aevalsrc=d=150:s=48000:exprs='0.22*clip((t-35)/10,0,1)*clip((135-t)/10,0,1)*
 st(0,floor(t*8))*0+st(1,t-ld(0)/8)*0+
 0.22*clip((t-35)/10,0,1)*clip((135-t)/10,0,1)*lt(mod(ld(0)*5,8),5)*exp(-ld(1)*35)*(1-ld(1)*8)*sin(2*PI*55*(8+mod(ld(0)*3,7))*ld(1))
 |
 st(0,floor(t*8.1))*0+st(1,t-ld(0)/8.1)*0+
 0.22*clip((t-35)/10,0,1)*clip((135-t)/10,0,1)*lt(mod(ld(0)*5,8),5)*exp(-ld(1)*35)*(1-ld(1)*8.1)*sin(2*PI*55*(8+mod(ld(0)*3,7))*ld(1))',
 aecho=in_gain=0.8:out_gain=0.8:delays=281|373:decays=0.35|0.3[pulse];

aevalsrc=d=150:s=48000:exprs='clip((150-t)/10,0,1)*(
 0.30*st(0,floor(t*16))*0+0.30*st(1,t-ld(0)/16)*0+0.30*st(2,mod(sin(ld(0)*12.9898)*43758.5453,1))*0+0.30*st(3,mod(sin(ld(0)*78.233)*12543.31,1))*0+
 0.30*st(4,55*pow(2,floor(ld(3)*3))*(4+floor(mod(ld(3)*37,5))))*0+
 0.30*lt(ld(2),0.10+0.75*clip((t-80)/50,0,1))*exp(-ld(1)*30)*(1-ld(1)*16)*sin(2*PI*ld(4)*ld(1)+1.5*exp(-ld(1)*12)*sin(2*PI*ld(4)*1.4142*ld(1)))
 +st(5,floor(t*2))*0+st(6,t-ld(5)/2)*0+st(7,mod(sin(ld(5)*39.346)*24634.6345,1))*0+st(8,mod(sin(ld(5)*11.135)*31415.926,1))*0+
 0.35*lt(ld(7),0.55)*exp(-ld(6)*3)*(1-ld(6)*2)*sin(2*PI*27.5*pow(2,1+floor(ld(8)*3))*(4+floor(mod(ld(8)*91,5)))*ld(6)+2.5*exp(-ld(6)*2)*sin(2*PI*27.5*pow(2,1+floor(ld(8)*3))*(4+floor(mod(ld(8)*91,5)))*2.7183*ld(6))))',
 pan=stereo|c0=c0|c1=c0,asplit[cdry][cwet0];
aevalsrc=d=4:s=48000:exprs='(random(0)*2-1)*exp(-t*1.7)|(random(1)*2-1)*exp(-t*1.7)',lowpass=f=7000[ir];
[cwet0][ir]afir[cwet];
[cdry][cwet]amix=inputs=2:weights=0.6 0.9:normalize=0[cloud];

[drone][pulse][cloud]amix=inputs=3:weights=1 1 1:normalize=0,
 highpass=f=25,alimiter=limit=0.9,afade=t=out:st=144:d=6
" "$@"
