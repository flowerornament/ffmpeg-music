#!/bin/bash
# xsh.sh out "x264 opts" "force_key_frames expr" dur : continuously gliding harmonic series through starved x264
O=$1; X=$2; K=$3; D=${4:-16}
ffmpeg -hide_banner -loglevel error -y -filter_complex "
color=c=black:s=32x2048:r=46.875:d=$((D+1)),format=gray,geq=lum='st(0,H-1-Y);st(1,24*pow(2,0.5*sin(2*PI*T/8)));st(6,0);st(7,1);while(lte(ld(7),8),st(6,ld(6)+exp(-pow((ld(0)-ld(1)*ld(7))/1.0,2))/ld(7));st(7,ld(7)+1));min(255,220*ld(6))',format=yuv420p[v]" -map "[v]" -c:v libx264 $X -force_key_frames "$K" -f null - -dec 0:0 -filter_complex "
[dec:0]fps=46.875,format=gray,crop=1:2048:16:0,pad=1:2049:0:1,geq=lum='p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*0.12'[m];
color=c=black:s=1x2049:r=46.875:d=$((D+1)),format=gray,geq=lum='255*mod((H-1-Y)*N/4,1)'[p];
[m][p]spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75[o]" -map "[o]" -t $D -c:a pcm_f32le $O.wav
./spec.sh $O.wav $O.png 1500 0 $D
