#!/bin/bash
# xgain.sh out "x264 opts" dur : chord loop, image gain g(t) sweeps 0.03->1->0.03 before x264, /g after decode
O=$1; X=$2; D=${3:-24}
G="(0.03+0.97*pow(sin(PI*T/$D),2))"
ffmpeg -hide_banner -loglevel error -y -filter_complex "
color=c=black:s=32x2048:r=1/3:d=$((D+3)),format=gray,geq=lum='st(0,H-1-Y);st(1,mod(floor(T/3+0.01),4));
st(2,if(eq(ld(1),0),24,if(eq(ld(1),1),20,if(eq(ld(1),2),16,18))));
st(3,if(eq(ld(1),0),30,if(eq(ld(1),1),25,if(eq(ld(1),2),20,22.5))));
st(4,if(eq(ld(1),0),36,if(eq(ld(1),1),32,if(eq(ld(1),2),27,27))));
st(5,if(eq(ld(1),0),45,if(eq(ld(1),1),40,if(eq(ld(1),2),36,32))));
st(6,0);st(7,1);while(lte(ld(7),8),st(6,ld(6)+(exp(-pow((ld(0)-ld(2)*ld(7))/1.0,2))+exp(-pow((ld(0)-ld(3)*ld(7))/1.0,2))+exp(-pow((ld(0)-ld(4)*ld(7))/1.0,2))+exp(-pow((ld(0)-ld(5)*ld(7))/1.0,2)))/ld(7));st(7,ld(7)+1));
min(255,250*ld(6))',fps=46.875,geq=lum='p(X,Y)*$G',format=yuv420p[v]" -map "[v]" -c:v libx264 $X -f null - -dec 0:0 -filter_complex "
[dec:0]fps=46.875,format=gray,crop=1:2048:16:0,pad=1:2049:0:1,geq=lum='p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*0.12/$G'[m];
color=c=black:s=1x2049:r=46.875:d=$((D+3)),format=gray,geq=lum='255*mod((H-1-Y)*N/4+sin((H-1-Y)*12.9898)*43758.5453,1)'[p];
[m][p]spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75[o]" -map "[o]" -t $D -c:a pcm_f32le $O.wav
./spec.sh $O.wav $O.png 2500 0 $D
