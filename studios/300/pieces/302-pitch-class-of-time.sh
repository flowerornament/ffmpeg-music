#!/bin/sh
# 302 — Pitch Class of Time (PHI No. 2)
# Every partial pulses at a rhythm that is its own pitch, folded by octaves into the range
# of a drum machine: row b (b x 11.71875 Hz) pulses at 1.953125 * 2^(log2(b/4) mod 3) Hz,
# i.e. at 117.19 bpm bin 4 plays quarters, 8 eighths, 16 sixteenths, 32 quarters again.
# Octave equivalence for time (Cowell's rhythmicon, Stockhausen's "...how time passes...").
# A just major triad 4:5:6 is a 4:5:6 polyrhythm; the bass changes groove with harmonic
# function — I (bin 6) plays 3 against 2, IV (bin 8) straight eighths, V (bin 9) 9 against 8,
# vi (bin 5) 5 against 4.
# Harmony moves by optical flow (minterpolate, as in 301): while a partial glides it crosses
# rows that pulse at different rates and phases, so every chord change is a stutter, a
# tempo smear, and every arrival locks back into the groove. Motion = rhythmic dissolution.
# The kick is the only sound not drawn as an image: an expression sine-drop on the quarter
# notes, reinforcing bin 4 (46.9 Hz), which the image pulses at the same rate.
# Air: the moving image stretched x4 (two octaves up) and pulsed by the same law.
# Left ear: exhaustive bidirectional search. Right ear: bilateral three-step on 8px blocks.
F=46.875
CH="st(9,floor(N/2));if(eq(ld(9),0),0624303648,if(eq(ld(9),1),0520304048,if(eq(ld(9),2),0824324048,if(eq(ld(9),3),0927364554,
if(eq(ld(9),4),0624303648,if(eq(ld(9),5),0520304048,if(eq(ld(9),6),0824324048,if(eq(ld(9),7),0928354263,
if(eq(ld(9),8),0624303648,if(eq(ld(9),9),0520304050,if(eq(ld(9),10),0724283542,if(eq(ld(9),11),0927364563,
if(eq(ld(9),12),0624303648,0624303648)))))))))))))"
TK="if(eq(N,0),0,if(eq(N,1),8.192,if(eq(N,2),12.288,if(eq(N,3),16.384,if(eq(N,4),20.48,if(eq(N,5),24.576,
if(eq(N,6),28.672,if(eq(N,7),32.768,if(eq(N,8),36.864,if(eq(N,9),40.96,if(eq(N,10),43.008,if(eq(N,11),45.056,
if(eq(N,12),47.104,if(eq(N,13),49.152,if(eq(N,14),51.2,if(eq(N,15),53.248,if(eq(N,16),57.344,if(eq(N,17),61.44,
if(eq(N,18),65.536,if(eq(N,19),69.632,if(eq(N,20),73.728,if(eq(N,21),77.824,if(eq(N,22),81.92,if(eq(N,23),90.112,
if(eq(N,24),98.304,if(eq(N,25),110,if(eq(N,26),130,150)))))))))))))))))))))))))))"
DRAW="st(0,H-1-Y);st(8,$CH);
st(1,mod(floor(ld(8)/100000000),100));st(2,mod(floor(ld(8)/1000000),100));st(3,mod(floor(ld(8)/10000),100));
st(4,mod(floor(ld(8)/100),100));st(5,mod(ld(8),100));
st(6,1.5*exp(-pow((ld(0)-4)/1.2,2))+1.3*exp(-pow((ld(0)-ld(1))/1.2,2))+0.6*exp(-pow((ld(0)-2*ld(1))/1.2,2)));st(7,1);
while(lte(ld(7),5),st(6,ld(6)+(exp(-pow((ld(0)-ld(2)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(3)*ld(7))/1.2,2))
 +exp(-pow((ld(0)-ld(4)*ld(7))/1.2,2))+0.8*exp(-pow((ld(0)-ld(5)*ld(7))/1.2,2)))/ld(7));st(7,ld(7)+1));
min(255,170*ld(6))"
# the pulse law (applied after peak-pick and the x4 air layer). ld(1)=bin, ld(2)=rate, ld(3)=depth of the pulse over the form.
PULSE="st(1,max(H-1-Y,1));st(2,1.953125*pow(2,mod(log(ld(1)/4)/log(2),3)));
st(3,clip((T-4)/12,0,1)*(1-0.7*between(T,81.92,98.304))*clip((118-T)/14,0,1));
p(X,Y)*(1-ld(3)+ld(3)*2.2*exp(-(4+ld(1)/6)*mod(ld(2)*T,1)))"
PICK="p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*0.13"
APICK="p(X,Y)*gte(p(X,Y),p(X,Y-1))*gt(p(X,Y),p(X,Y+1))*0.6"
EYEL="format=gray,crop=1:2049:16:0,geq=lum='$PICK',split[bL][aL];[aL]scale=1:8196:flags=neighbor,crop=1:2049:0:6147,geq=lum='$APICK'[sL];[bL][sL]blend=all_mode=addition,geq=lum='$PULSE'"
EYER="format=gray,crop=1:2049:16:0,geq=lum='$PICK',split[bR][aR];[aR]scale=1:8196:flags=neighbor,crop=1:2049:0:6147,geq=lum='$APICK'[sR];[bR][sR]blend=all_mode=addition,geq=lum='$PULSE'"
PHASE="255*mod((H-1-Y)*N/4+sin((H-1-Y)*12.9898)*43758.5453,1)"
SYN="spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75,aformat=channel_layouts=mono"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=32x2049:r=1:d=28,format=gray,geq=lum='$DRAW',setpts='($TK)/TB',split[k1][k2];
[k1]minterpolate=fps=$F:mi_mode=mci:scd=none:me_mode=bidir:me=esa:search_param=32,$EYEL[mL];
[k2]minterpolate=fps=$F:mi_mode=mci:scd=none:me_mode=bilat:me=tss:mb_size=8,$EYER[mR];
color=c=black:s=1x2049:r=$F:d=125,format=gray,geq=lum='$PHASE',split[pL][pR];
[mL][pL]$SYN[l];[mR][pR]$SYN[r];
[l][r]join=inputs=2:channel_layout=stereo,atrim=0:118[harm];
aevalsrc=d=118:s=48000:exprs='st(0,mod(t,0.512));st(1,clip((t-12.288)/0.1,0,1)*(1-between(t,81.92,98.304))*clip((116-t)/6,0,1));
 0.55*ld(1)*exp(-ld(0)*9)*sin(2*PI*(46.875*ld(0)+140*(1-exp(-ld(0)*30))/30))',pan=stereo|c0=c0|c1=c0[kick];
[harm]asplit[dry][w];
aevalsrc=d=3:s=48000:exprs='(random(0)*2-1)*exp(-t*2.2)|(random(1)*2-1)*exp(-t*2.2)',lowpass=f=7000[ir];
[w]highpass=f=200[w2];[w2][ir]afir=dry=1:wet=1[wet];
[dry][wet][kick]amix=inputs=3:weights=1 0.2 1:normalize=0,highpass=f=25,
 acompressor=threshold=0.2:ratio=3:attack=8:release=200,volume=1.6,alimiter=limit=0.8:level=0,
 afade=t=in:d=2,afade=t=out:st=110:d=8
" "$@"
