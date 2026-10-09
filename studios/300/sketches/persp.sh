#!/bin/bash
# perspective tilt of a harmonic chord: p(t) 0 -> 0.95 -> 0 over D seconds
O=$1; D=${2:-30}
ffmpeg -hide_banner -loglevel error -y -filter_complex "
color=c=black:s=64x2049:r=46.875:d=$D,format=gray,geq=lum='st(0,H-1-Y);st(6,0);st(7,1);while(lte(ld(7),12),st(6,ld(6)+(exp(-pow((ld(0)-24*ld(7))/1.0,2))+exp(-pow((ld(0)-30*ld(7))/1.0,2))+exp(-pow((ld(0)-36*ld(7))/1.0,2)))/ld(7));st(7,ld(7)+1));min(255,200*ld(6))',
perspective=x0='W/2*0.97*sin(PI*on/(46.875*$D))':y0=0:x1='W-W/2*0.97*sin(PI*on/(46.875*$D))':y1=0:x2=0:y2=H:x3=W:y3=H:interpolation=linear:sense=destination:eval=frame,
crop=1:2049:32:0,geq=lum='p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*0.12'[m];
color=c=black:s=1x2049:r=46.875:d=$D,format=gray,geq=lum='255*mod((H-1-Y)*N/4+sin((H-1-Y)*12.9898)*43758.5453,1)'[p];
[m][p]spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75" -c:a pcm_f32le $O.wav
./spec.sh $O.wav $O.png 4000 0 $D
