#!/bin/bash
# x264.sh out "x264 opts"  : JI chord loop drawn every 3 s, held (dup) at 46.875 fps, through libx264 via loopback, peak-pick, resynth
O=$1; X=$2; D=${3:-24}
ffmpeg -hide_banner -loglevel error -y -filter_complex "
color=c=black:s=64x2048:r=1/3:d=$((D+3)),format=gray,geq=lum='st(0,H-1-Y);st(1,mod(floor(T/3+0.01),4));
st(2,if(eq(ld(1),0),24,if(eq(ld(1),1),20,if(eq(ld(1),2),16,18))));
st(3,if(eq(ld(1),0),30,if(eq(ld(1),1),25,if(eq(ld(1),2),20,22.5))));
st(4,if(eq(ld(1),0),36,if(eq(ld(1),1),32,if(eq(ld(1),2),27,27))));
st(5,if(eq(ld(1),0),45,if(eq(ld(1),1),40,if(eq(ld(1),2),36,32))));
st(6,0);st(7,1);while(lte(ld(7),5),st(6,ld(6)+(exp(-pow((ld(0)-ld(2)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(3)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(4)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(5)*ld(7))/1.2,2)))/ld(7));st(7,ld(7)+1));
min(255,200*ld(6))',fps=46.875,format=yuv420p[v]" -map "[v]" -c:v libx264 $X -f null - -dec 0:0 -filter_complex "
[dec:0]fps=46.875,format=gray,crop=1:2048:32:0,pad=1:2049:0:1,geq=lum='p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*0.12'[m];
color=c=black:s=1x2049:r=46.875:d=$((D+3)),format=gray,geq=lum='255*mod((H-1-Y)*N/4,1)'[p];
[m][p]spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75[o]" -map "[o]" -t $D -c:a pcm_f32le $O.wav
./spec.sh $O.wav $O.png 1500 0 $D
