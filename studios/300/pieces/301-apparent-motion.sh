#!/bin/sh
# 301 — Apparent Motion (PHI No. 1)
# (the last keyframe is a dummy: minterpolate drops the final segment at end of stream)
# Chords are drawn as still images of spectra, a few seconds apart. FFmpeg's motion-
# compensated frame interpolator (minterpolate), built to invent the frames between two
# video frames, decides how every partial travels from one chord to the next: it believes
# the partials are objects and computes their motion vectors. The voice leading is the
# optical flow. Wertheimer's phi phenomenon (two flashes seen as one moving thing),
# applied to harmony.
#
#  tuning   FFT bins as frets: spectrumsynth at h=2049 is an inverse FFT of 4096 at 48 kHz,
#           so every bin is a harmonic of 11.71875 Hz. Tonic = bin 24 (281.25 Hz); the
#           5-limit major scale (24 27 30 32 36 40 45 48) and the 7-limit sevenths
#           (21 28 35 42 63) lie on integer bins. Glides step through the bins, so a voice
#           falling from 24 to 20 plays harmonics 24 23 22 21 20 — the overtone scale.
#  chords   five voices packed in one 10-digit number: bass|v1|v2|v3|v4 (2 digits each).
#           Each chord is two keyframes (arrive, depart): it rests, then the eye moves it.
#  form     a slow phrase I I7 IV IV7 bIII7 vi V7 I; an accelerating second phrase whose
#           chords last a breath; the dominant held; then the V7 -> I cadence stretched into
#           one 20-second glide; the tonic, high, for the end.
#  eyes     left ear: exhaustive bidirectional search (faithful, parsimonious voice
#           leading, common tones held). right ear: bilateral three-step search on 8px
#           blocks (partials fan out in chevrons). The ears agree on arrivals and
#           disagree in motion, so the stereo field opens in every transition.
#  partials after interpolation a geq keeps only local maxima (one bin per partial); the
#           phase image advances each bin by bin*hop/N cycles per frame so every bin is a
#           continuous sinusoid.
#  air      the same moving image stretched x4 vertically (nearest neighbour) = the same
#           music two octaves up, quietly.
#  pulse    the rhythmicon (Cowell): row b pulses b times every 16 s, so a 4:5:6 chord is
#           also a 4:5:6 polyrhythm and everything realigns every 16 s. Applied after the
#           air layer, so the transposed partials pulse 4x faster: the hats are the
#           harmony two octaves up. It fades in for the second phrase.
F=46.875
CH="st(9,floor(N/2));if(eq(ld(9),0),0624303648,if(eq(ld(9),1),0624303642,if(eq(ld(9),2),0824324048,if(eq(ld(9),3),0828324056,
if(eq(ld(9),4),0728354249,if(eq(ld(9),5),0520304048,if(eq(ld(9),6),0927364563,if(eq(ld(9),7),0624303648,
if(eq(ld(9),8),0525304050,if(eq(ld(9),9),0824324048,if(eq(ld(9),10),0728354249,if(eq(ld(9),11),0927364563,
if(eq(ld(9),12),0520304048,if(eq(ld(9),13),0728354256,if(eq(ld(9),14),0828324056,if(eq(ld(9),15),0721283542,
if(eq(ld(9),16),0927364563,if(eq(ld(9),17),0728354249,if(eq(ld(9),18),0824324048,if(eq(ld(9),19),0927364563,
if(eq(ld(9),20),0624303648,0612243648)))))))))))))))))))))"
TK="if(eq(N,0),0,if(eq(N,1),6,if(eq(N,2),10,if(eq(N,3),14,if(eq(N,4),18,if(eq(N,5),22,if(eq(N,6),26,if(eq(N,7),28,
if(eq(N,8),32,if(eq(N,9),34,if(eq(N,10),38,if(eq(N,11),42,if(eq(N,12),46,if(eq(N,13),50,if(eq(N,14),56,if(eq(N,15),60,
if(eq(N,16),63,if(eq(N,17),64,if(eq(N,18),66.5,if(eq(N,19),67.5,if(eq(N,20),70,if(eq(N,21),71,if(eq(N,22),73.5,if(eq(N,23),74.5,
if(eq(N,24),77,if(eq(N,25),77.5,if(eq(N,26),79.5,if(eq(N,27),80,if(eq(N,28),82,if(eq(N,29),82.5,if(eq(N,30),84,if(eq(N,31),84.5,
if(eq(N,32),86,if(eq(N,33),86.3,if(eq(N,34),88,if(eq(N,35),88.3,if(eq(N,36),90,if(eq(N,37),90.3,if(eq(N,38),92,if(eq(N,39),98,
if(eq(N,40),118,if(eq(N,41),124,if(eq(N,42),132,if(eq(N,43),150,if(eq(N,44),170,200)))))))))))))))))))))))))))))))))))))))))))))"
DRAW="st(0,H-1-Y);st(8,$CH);
st(1,mod(floor(ld(8)/100000000),100));st(2,mod(floor(ld(8)/1000000),100));st(3,mod(floor(ld(8)/10000),100));
st(4,mod(floor(ld(8)/100),100));st(5,mod(ld(8),100));
st(6,1.6*eq(mod(ld(1),2),0)*exp(-pow((ld(0)-ld(1)/2)/1.2,2)));st(7,1);
while(lte(ld(7),6),st(6,ld(6)+(1.4*exp(-pow((ld(0)-ld(1)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(2)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(3)*ld(7))/1.2,2))
 +exp(-pow((ld(0)-ld(4)*ld(7))/1.2,2))+0.8*exp(-pow((ld(0)-ld(5)*ld(7))/1.2,2)))/ld(7));st(7,ld(7)+1));
min(255,170*ld(6))"
PICK="p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*0.1"
APICK="p(X,Y)*gte(p(X,Y),p(X,Y-1))*gt(p(X,Y),p(X,Y+1))*0.5"
GATE="p(X,Y)*(1+st(9,clip((T-60)/12,0,1)*clip((150-T)/20,0,1))*(1.8*exp(-5*mod((H-1-Y)*T/16,1))-1))"
EYEL="format=gray,crop=1:2049:16:0,geq=lum='$PICK',split[bL][aL];[aL]scale=1:8196:flags=neighbor,crop=1:2049:0:6147,geq=lum='$APICK'[sL];[bL][sL]blend=all_mode=addition,geq=lum='$GATE'"
EYER="format=gray,crop=1:2049:16:0,geq=lum='$PICK',split[bR][aR];[aR]scale=1:8196:flags=neighbor,crop=1:2049:0:6147,geq=lum='$APICK'[sR];[bR][sR]blend=all_mode=addition,geq=lum='$GATE'"
PHASE="255*mod((H-1-Y)*N/4+sin((H-1-Y)*12.9898)*43758.5453,1)"
SYN="spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75,aformat=channel_layouts=mono"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=32x2049:r=1:d=46,format=gray,geq=lum='$DRAW',setpts='($TK)/TB',split[k1][k2];
[k1]minterpolate=fps=$F:mi_mode=mci:scd=none:me_mode=bidir:me=esa:search_param=32,$EYEL[mL];
[k2]minterpolate=fps=$F:mi_mode=mci:scd=none:me_mode=bilat:me=tss:mb_size=8,$EYER[mR];
color=c=black:s=1x2049:r=$F:d=172,format=gray,geq=lum='$PHASE',split[pL][pR];
[mL][pL]$SYN[l];[mR][pR]$SYN[r];
[l][r]join=inputs=2:channel_layout=stereo,atrim=0:162,asplit[dry][w];
aevalsrc=d=5:s=48000:exprs='(random(0)*2-1)*exp(-t*1.3)|(random(1)*2-1)*exp(-t*1.3)',lowpass=f=6000[ir];
[w][ir]afir=dry=1:wet=1[wet];
[dry][wet]amix=inputs=2:weights=1 0.25:normalize=0,highpass=f=28,
 acompressor=threshold=0.25:ratio=2.5:attack=20:release=300,volume=1.5,alimiter=limit=0.8:level=0,
 afade=t=in:d=3,afade=t=out:st=147:d=15
" "$@"
