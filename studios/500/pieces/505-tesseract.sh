#!/bin/sh
# 505 — Tesseract
# A room that cannot be built: four-dimensional. Its modes are
#   f(l,m,n,p) = sqrt((l*36.67)^2 + (m*45.83)^2 + (n*55)^2 + (p*68.75)^2)
# so its four axial series are D, F#, A, C# — a just Dmaj7 — and its tangential, oblique
# and "hyper-oblique" modes (three and four nonzero indices; weights .45, .2, .09) are the
# inharmonic air between them. The room is excited by breath (pink noise swelling every
# 11 s) and by a soft knock every 3.75 s; a little of the breath also reaches you directly.
# You walk through it. Six listening places along a path through the hypercube, each with
# two ears; mode amplitudes are products of four cosines at source and listener, so each
# place hears a different voicing of the same chord: near a corner the whole low chord;
# near the centre odd modes cancel in every dimension and the chord lifts an octave;
# halfway along one axis only, that axis's note thins out. Walking = slow crossfade
# between the places (after convolution, as for a moving listener). 12-channel afir.
# IRs computed at 3 kHz (modes capped at 1.4 kHz) and resampled.
R4(){ # listener position x y z w
echo "st(6,0);st(0,0);while(lt(ld(0),5),st(1,0);while(lt(ld(1),5),st(2,0);while(lt(ld(2),5),st(3,0);while(lt(ld(3),5),st(5,gt(ld(0),0)+gt(ld(1),0)+gt(ld(2),0)+gt(ld(3),0));st(4,sqrt(pow(ld(0)*36.67,2)+pow(ld(1)*45.83,2)+pow(ld(2)*55,2)+pow(ld(3)*68.75,2)));st(6,ld(6)+gte(ld(5),2)*lt(ld(4),1400)*pow(0.45,ld(5)-1)*cos(PI*ld(0)*0.07)*cos(PI*ld(1)*0.11)*cos(PI*ld(2)*0.05)*cos(PI*ld(3)*0.13)*cos(PI*ld(0)*$1)*cos(PI*ld(1)*$2)*cos(PI*ld(2)*$3)*cos(PI*ld(3)*$4)*exp(-t*(1.3+ld(4)/320))*sin(2*PI*ld(4)*t));st(3,ld(3)+1));st(2,ld(2)+1));st(1,ld(1)+1));st(0,ld(0)+1));st(0,1);while(lt(ld(0),38),st(4,ld(0)*36.67);st(6,ld(6)+lt(ld(4),1400)*cos(PI*ld(0)*0.07)*cos(PI*ld(0)*$1)*exp(-t*(1.3+ld(4)/320))*sin(2*PI*ld(4)*t));st(4,ld(0)*45.83);st(6,ld(6)+lt(ld(4),1400)*cos(PI*ld(0)*0.11)*cos(PI*ld(0)*$2)*exp(-t*(1.3+ld(4)/320))*sin(2*PI*ld(4)*t));st(4,ld(0)*55);st(6,ld(6)+lt(ld(4),1400)*cos(PI*ld(0)*0.05)*cos(PI*ld(0)*$3)*exp(-t*(1.3+ld(4)/320))*sin(2*PI*ld(4)*t));st(4,ld(0)*68.75);st(6,ld(6)+lt(ld(4),1400)*cos(PI*ld(0)*0.13)*cos(PI*ld(0)*$4)*exp(-t*(1.3+ld(4)/320))*sin(2*PI*ld(4)*t));st(0,ld(0)+1));0.03*ld(6)"
}
# the walk: six places (left ear | right ear)
P0L="0.02 0.03 0.05 0.01"; P0R="0.06 0.01 0.02 0.04"     # near a corner
P1L="0.21 0.09 0.33 0.12"; P1R="0.25 0.05 0.29 0.16"
P2L="0.50 0.48 0.52 0.49"; P2R="0.47 0.51 0.49 0.53"     # the centre
P3L="0.50 0.02 0.04 0.03"; P3R="0.52 0.05 0.01 0.06"     # halfway along D only
P4L="0.04 0.03 0.50 0.51"; P4R="0.01 0.06 0.49 0.47"     # halfway along A and C#
P5L="0.31 0.27 0.12 0.08"; P5R="0.35 0.22 0.15 0.11"
# windows: place k is heard around 30k s (raised-cosine crossfades, 30 s apart)
WIN(){ echo "volume='max(0,cos(PI*min(1,abs(t-$1)/30))*0.5+0.5)*gt(30,abs(t-$1))':eval=frame"; }
ffmpeg -hide_banner -y -filter_complex "
anoisesrc=r=48000:d=190:c=white:a=0.3:s=505,volume='0.35+0.65*pow(0.5-0.5*cos(2*PI*t/11),2)':eval=frame,asplit[breath][b2];
[b2]highpass=f=3500,highpass=f=3500,lowpass=f=12000,pan=stereo|c0=c0|c1=c0,adecorrelate=stages=10,volume=0.7[air];
aevalsrc=s=48000:d=190:exprs='st(0,floor(t/3.75));st(1,t-ld(0)*3.75);st(2,mod(sin(ld(0)*7.31)*43758.5453,1));(0.5+0.5*ld(2))*lt(ld(1),0.012)*(1-cos(2*PI*ld(1)/0.012))/2*1.5'[knock];
[breath][knock]amix=inputs=2:normalize=0,pan=12c|c0=c0|c1=c0|c2=c0|c3=c0|c4=c0|c5=c0|c6=c0|c7=c0|c8=c0|c9=c0|c10=c0|c11=c0[x];
aevalsrc=s=3000:d=5:exprs='$(R4 $P0L)|$(R4 $P0R)|$(R4 $P1L)|$(R4 $P1R)|$(R4 $P2L)|$(R4 $P2R)|$(R4 $P3L)|$(R4 $P3R)|$(R4 $P4L)|$(R4 $P4R)|$(R4 $P5L)|$(R4 $P5R)',aresample=48000[ir];
[x][ir]afir=irnorm=-1:irfmt=input,asplit=6[y0][y1][y2][y3][y4][y5];
[y0]pan=stereo|c0=c0|c1=c1,$(WIN 0)[w0];[y1]pan=stereo|c0=c2|c1=c3,$(WIN 30)[w1];[y2]pan=stereo|c0=c4|c1=c5,$(WIN 60)[w2];
[y3]pan=stereo|c0=c6|c1=c7,$(WIN 90)[w3];[y4]pan=stereo|c0=c8|c1=c9,$(WIN 120)[w4];[y5]pan=stereo|c0=c10|c1=c11,volume='min(1,max(0,(t-120)/30))':eval=frame[w5];
[w0][w1][w2][w3][w4][w5][air]amix=inputs=7:normalize=0,volume=0.14,
acompressor=threshold=0.4:ratio=2:attack=30:release=400,alimiter=level=0:limit=0.8,afade=t=in:d=6,afade=t=out:st=172:d=18" "$@"
