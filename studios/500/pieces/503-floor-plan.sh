#!/bin/sh
# 503 — Floor Plan
# A drum kit made of architecture. Four rectangular rooms, built from the modal formula
#   f(l,m,n) = sqrt((l*fx)^2 + (m*fy)^2 + (n*fz)^2)
# whose three axial fundamentals are the three notes of a just triad, so each room's axial
# modes are three harmonic series = a chord, and its tangential/oblique modes are the
# inharmonic shimmer between them. Progression of rooms (2 bars each):
#   A (55, 68.75, 82.5)  F#m (45.83, 55, 68.75)  D (36.67, 45.83, 55)  E (41.25, 51.56, 61.88)
# Every drum is a KNOCK at a place in the room. Where you knock decides which modes sound:
# a mode's amplitude is cos(l*pi*x)cos(m*pi*y)cos(n*pi*z) at source and listener.
#   corner (0,0,0)      every mode — the full low chord: kick
#   centre (.5,.5,.5)   every odd mode cancels — the chord jumps an octave: snare
#   mid-wall (.5,0,0)   the root's odd modes cancel — 3rd and 5th remain: tom
# Two ears at two points of the room give the stereo image (different mode shapes per ear).
# Hats are knocks in a small box (880, 1100, 1320 Hz) computed at 24 kHz.
# Mallet hardness = raised-cosine pulse width; louder knocks are harder and brighter
# (kick 9->4 ms, tom 5->1.5 ms, snare 0.7 ms + grit).
# 125 bpm, 16ths. Pattern masks read as bits: kick 1089/9281, snare 36880 (+ghosts 38032 in
# sections 4-5), tom E(5,16)=18724 (E(7,16)=19093 in 7-8). A little of the dry mallet
# contact (high-passed) sits on top, as it does when you really knock on a wall.
# The IRs are computed at 4 kHz (all modes < 2 kHz) and resampled; 24-channel afir does
# 4 rooms x 3 places x 2 ears at once, so every tail rings to its end across chord changes.
room(){ # fx fy fz  sx sy sz  rx ry rz  damping
# axial modes of each dimension up to 1.9 kHz (24 harmonics), then the low block of
# tangential (x.45) and oblique (x.2) modes. Damping grows with frequency.
echo "st(4,0);st(0,1);while(lt(ld(0),25),st(3,ld(0)*$1);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$4)*cos(PI*ld(0)*$7)*exp(-t*(${10}+ld(3)/100))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));st(0,1);while(lt(ld(0),25),st(3,ld(0)*$2);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$5)*cos(PI*ld(0)*$8)*exp(-t*(${10}+ld(3)/100))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));st(0,1);while(lt(ld(0),25),st(3,ld(0)*$3);st(4,ld(4)+lt(ld(3),1900)*cos(PI*ld(0)*$6)*cos(PI*ld(0)*$9)*exp(-t*(${10}+ld(3)/100))*sin(2*PI*ld(3)*t));st(0,ld(0)+1));st(0,0);while(lt(ld(0),6),st(1,0);while(lt(ld(1),6),st(2,0);while(lt(ld(2),5),st(5,gt(ld(0),0)+gt(ld(1),0)+gt(ld(2),0));st(3,sqrt(pow(ld(0)*$1,2)+pow(ld(1)*$2,2)+pow(ld(2)*$3,2)));st(4,ld(4)+gte(ld(5),2)*pow(0.45,ld(5)-1)*cos(PI*ld(0)*$4)*cos(PI*ld(1)*$5)*cos(PI*ld(2)*$6)*cos(PI*ld(0)*$7)*cos(PI*ld(1)*$8)*cos(PI*ld(2)*$9)*exp(-t*(${10}+ld(3)/100))*sin(2*PI*ld(3)*t));st(2,ld(2)+1));st(1,ld(1)+1));st(0,ld(0)+1));0.04*ld(4)"
}
box(){ # small room for hats, ear position
echo "st(4,0);st(0,0);while(lt(ld(0),5),st(1,0);while(lt(ld(1),5),st(2,0);while(lt(ld(2),5),st(3,sqrt(pow(ld(0)*880,2)+pow(ld(1)*1100,2)+pow(ld(2)*1320,2)));st(4,ld(4)+gt(ld(0)+ld(1)+ld(2),0)*cos(PI*ld(0)*0.13)*cos(PI*ld(1)*0.29)*cos(PI*ld(2)*0.41)*cos(PI*ld(0)*$1)*cos(PI*ld(1)*$2)*cos(PI*ld(2)*$3)*exp(-t*(25+ld(3)/90))*sin(2*PI*ld(3)*t));st(2,ld(2)+1));st(1,ld(1)+1));st(0,ld(0)+1));0.03*ld(4)"
}
EL="0.11 0.07 0.19"; ER="0.17 0.13 0.05"     # the two ears
A="55 68.75 82.5"; FS="45.83 55 68.75"; D="36.67 45.83 55"; E="41.25 51.56 61.88"
K="0 0 0"; S="0.5 0.5 0.5"; T="0.5 0 0"   # where you knock
KD=7; SD=14; TD=9                                # how damped each place is
# clock: s step, u time since step, c room (chord), q section (16 bars of 1.92 s = 15.36 s)
HEAD="st(0,floor(t*125/15));st(1,t-ld(0)*15/125);st(2,mod(floor(ld(0)/32),4));st(3,floor(t/15.36));st(5,mod(ld(0),16));st(6,mod(sin(ld(0)*12.9898)*43758.5453,1))"
KICK="$HEAD;st(7,mod(floor(if(mod(floor(ld(0)/16),2),9281,1089)/pow(2,ld(5))),2));ld(7)*not(between(ld(3),6,6))*lt(ld(3),9)*st(8,0.009-0.005*ld(6));(0.4+0.3*ld(6))*lt(ld(1),ld(8))*(1-cos(2*PI*ld(1)/ld(8)))/2"
SNR="$HEAD;st(7,mod(floor(if(between(ld(3),4,5),38032,36880)/pow(2,ld(5))),2));ld(7)*gte(ld(3),2)*lt(ld(3),9)*(0.5+0.5*ld(6)*eq(ld(5),15)+0.5*not(eq(ld(5),15)))*(lt(ld(1),0.0007)*(1-cos(2*PI*ld(1)/0.0007))/2+0.25*(random(9)*2-1)*exp(-ld(1)*90))"
TOM="$HEAD;st(7,mod(floor(if(between(ld(3),7,8),19093,18724)/pow(2,ld(5))),2));ld(7)*gte(ld(3),1)*st(8,0.005-0.0035*ld(6));(0.35+0.45*ld(6))*lt(ld(1),ld(8))*(1-cos(2*PI*ld(1)/ld(8)))/2"
HAT="$HEAD;gte(ld(3),2)*not(between(ld(3),6,6))*lt(ld(3),9)*(0.15+0.6*eq(mod(ld(5),4),2)+0.25*ld(6))*lt(ld(1),0.0003)"
C(){ echo "eq(ld(2),$1)*($2)"; }   # gate an excitation to room c
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=150:exprs='$(C 0 "$KICK")|$(C 0 "$KICK")|$(C 0 "$SNR")|$(C 0 "$SNR")|$(C 0 "$TOM")|$(C 0 "$TOM")|$(C 1 "$KICK")|$(C 1 "$KICK")|$(C 1 "$SNR")|$(C 1 "$SNR")|$(C 1 "$TOM")|$(C 1 "$TOM")|$(C 2 "$KICK")|$(C 2 "$KICK")|$(C 2 "$SNR")|$(C 2 "$SNR")|$(C 2 "$TOM")|$(C 2 "$TOM")|$(C 3 "$KICK")|$(C 3 "$KICK")|$(C 3 "$SNR")|$(C 3 "$SNR")|$(C 3 "$TOM")|$(C 3 "$TOM")'[x];
aevalsrc=s=4000:d=2:exprs='$(room $A $K $EL $KD)|$(room $A $K $ER $KD)|$(room $A $S $EL $SD)|$(room $A $S $ER $SD)|$(room $A $T $EL $TD)|$(room $A $T $ER $TD)|$(room $FS $K $EL $KD)|$(room $FS $K $ER $KD)|$(room $FS $S $EL $SD)|$(room $FS $S $ER $SD)|$(room $FS $T $EL $TD)|$(room $FS $T $ER $TD)|$(room $D $K $EL $KD)|$(room $D $K $ER $KD)|$(room $D $S $EL $SD)|$(room $D $S $ER $SD)|$(room $D $T $EL $TD)|$(room $D $T $ER $TD)|$(room $E $K $EL $KD)|$(room $E $K $ER $KD)|$(room $E $S $EL $SD)|$(room $E $S $ER $SD)|$(room $E $T $EL $TD)|$(room $E $T $ER $TD)',aresample=48000[ir];
[x]asplit[x][xd];[xd]pan=stereo|c0=c0+c2+c4+c6+c8+c10+c12+c14+c16+c18+c20+c22|c1=c1+c3+c5+c7+c9+c11+c13+c15+c17+c19+c21+c23,highpass=f=700,highpass=f=700[dry];[x][ir]afir=irnorm=-1:irfmt=input,
pan=stereo|c0=c0+c2+c4+c6+c8+c10+c12+c14+c16+c18+c20+c22|c1=c1+c3+c5+c7+c9+c11+c13+c15+c17+c19+c21+c23[rooms];
aevalsrc=s=48000:d=150:exprs='$HAT'[hx];
aevalsrc=s=24000:d=0.5:exprs='$(box 0.07 0.11 0.03)|$(box 0.23 0.05 0.17)',aresample=48000[hir];
[hx]pan=stereo|c0=c0|c1=c0[hx2];[hx2][hir]afir=irnorm=-1:irfmt=input,highpass=f=3000[hats];
[rooms][hats][dry]amix=inputs=3:weights=1 28 0.3:normalize=0,volume=0.07,equalizer=f=900:t=o:w=2.5:g=6,lowshelf=f=90:g=-2,
acompressor=threshold=0.5:ratio=2:attack=5:release=150,alimiter=level=0:limit=0.89,afade=t=out:st=140:d=10" "$@"
