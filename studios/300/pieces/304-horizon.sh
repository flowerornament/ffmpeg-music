#!/bin/sh
# 304 — Horizon (PHI No. 4)
# A slow piece about looking at a chord from an angle.
#  chords      just-intonation chords as spectrum images (bins = harmonics of 11.71875 Hz,
#              tonic bin 24), twelve harmonics per voice, each held 20 s; minterpolate
#              (optical flow) carries every partial to the next chord in 12-second glides.
#  perspective `perspective` (the keystone corrector) pinches the top of the image into a
#              trapezoid, as if the spectrum were a floor receding to a horizon. Foreshortening
#              is projective, so the partials crowd non-linearly toward the bottom: the just
#              chord bends gently out of harmonicity and back, once per chord, like breathing.
#              At the climax the camera tilts almost flat and the dominant falls toward the
#              horizon, every partial curving down at its own speed, then rises back.
#  two clocks  the left ear is synthesized at 48000 Hz, the right at 47800 and resampled: the
#              same image read by a clock 0.42% slow. Every right-ear partial is 0.42% (7 cents)
#              flat, so the ears beat at a rate proportional to pitch (1.2 Hz at the tonic, 5 Hz
#              four octaves up), and the right ear drifts late across the piece (Reich phasing).
#              Radigue's beating and Reich's phase from one number. (Ears cross-blended 72/28,
#              bass below 150 Hz in mono, so the room keeps a centre.)
#  air         the image stretched x4 (two octaves up), quietly; long noise-convolution room.
F=46.875
CH="st(9,floor(N/2));if(eq(ld(9),0),0624303648,if(eq(ld(9),1),0520304048,if(eq(ld(9),2),0728354249,if(eq(ld(9),3),0824324048,
if(eq(ld(9),4),0421283542,if(eq(ld(9),5),0520253040,if(eq(ld(9),6),0927364563,if(eq(ld(9),7),0624303648,0312243648))))))))"
TK="if(lt(N,18),floor(N/2)*32+if(mod(N,2),20,0),if(eq(N,18),320,350))"
DRAW="st(0,H-1-Y);st(8,$CH);
st(1,mod(floor(ld(8)/100000000),100));st(2,mod(floor(ld(8)/1000000),100));st(3,mod(floor(ld(8)/10000),100));
st(4,mod(floor(ld(8)/100),100));st(5,mod(ld(8),100));
st(6,0);st(7,1);
while(lte(ld(7),12),st(6,ld(6)+(1.5*exp(-pow((ld(0)-ld(1)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(2)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(3)*ld(7))/1.2,2))
 +exp(-pow((ld(0)-ld(4)*ld(7))/1.2,2))+0.7*exp(-pow((ld(0)-ld(5)*ld(7))/1.2,2)))/pow(ld(7),1.2));st(7,ld(7)+1));
min(255,170*ld(6))"
# tilt p(t): breathing 0..0.06 each 32-s chord cycle, plus the fall (0.93) centred on 202 s
TILT="(0.06*pow(sin(PI*on/($F*32)),2)+0.77*exp(-pow((on/$F-202)/7,2)))"
PERSP="perspective=x0='W/2*$TILT':y0=0:x1='W-W/2*$TILT':y1=0:x2=0:y2=H:x3=W:y3=H:interpolation=linear:sense=destination:eval=frame"
PICK="p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*0.11"
APICK="p(X,Y)*gte(p(X,Y),p(X,Y-1))*gt(p(X,Y),p(X,Y+1))*0.4"
PHASE="255*mod((H-1-Y)*N/4+sin((H-1-Y)*12.9898)*43758.5453,1)"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=32x2049:r=1:d=20,format=gray,geq=lum='$DRAW',setpts='($TK)/TB',
 minterpolate=fps=$F:mi_mode=mci:scd=none:me_mode=bidir:me=esa:search_param=32,format=gray,$PERSP,crop=1:2049:16:0,
 geq=lum='$PICK',split[b][a];[a]scale=1:8196:flags=neighbor,crop=1:2049:0:6147,geq=lum='$APICK'[s];
 [b][s]blend=all_mode=addition,split[mL][mR];
color=c=black:s=1x2049:r=$F:d=335,format=gray,geq=lum='$PHASE',split[pL][pR];
[mL][pL]spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75,aformat=channel_layouts=mono[l];
[mR][pR]spectrumsynth=sample_rate=47800:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75,aresample=48000,aformat=channel_layouts=mono[r];
[l][r]join=inputs=2:channel_layout=stereo,atrim=0:312,pan=stereo|c0=0.72*c0+0.28*c1|c1=0.72*c1+0.28*c0,
 asplit[hi0][lo0];[lo0]lowpass=f=150,lowpass=f=150,pan=stereo|c0=0.5*c0+0.5*c1|c1=0.5*c0+0.5*c1[lo];
 [hi0]highpass=f=150,highpass=f=150[hi];[lo][hi]amix=inputs=2:normalize=0,asplit[dry][w];
aevalsrc=d=7:s=48000:exprs='(random(0)*2-1)*exp(-t*0.9)|(random(1)*2-1)*exp(-t*0.9)',lowpass=f=5000[ir];
[w]highpass=f=120[w2];[w2][ir]afir=dry=1:wet=1[wet];
[dry][wet]amix=inputs=2:weights=1 0.3:normalize=0,highpass=f=22,
 acompressor=threshold=0.2:ratio=2:attack=50:release=600,volume=1.3,alimiter=limit=0.89:level=0,
 afade=t=in:d=8,afade=t=out:st=296:d=16
" "$@"
