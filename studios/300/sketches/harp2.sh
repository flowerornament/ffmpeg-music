#!/bin/bash
O=$1; D=${2:-16}
STRIKE="st(1,max(H-1-Y,1));st(2,floor(N/6));st(3,N-6*ld(2));st(4,floor(4*clip((log(ld(1))/log(2)-3.5)/3,0,1)));
st(5,lt(mod(ld(2)*5,16),5));
p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*ld(5)*eq(ld(3),ld(4)+mod(ld(2),2))*if(lt(ld(1),16),eq(mod(ld(2),4),0),1)*0.2"
ffmpeg -hide_banner -loglevel error -y -filter_complex "
color=c=black:s=32x2049:r=1/4:d=$((D+8)),format=gray,geq=lum='st(0,H-1-Y);st(1,mod(floor(T/4+0.01),4));
st(2,if(eq(ld(1),0),24,if(eq(ld(1),1),20,if(eq(ld(1),2),16,18))));
st(3,if(eq(ld(1),0),30,if(eq(ld(1),1),25,if(eq(ld(1),2),20,22.5))));
st(4,if(eq(ld(1),0),36,if(eq(ld(1),1),32,if(eq(ld(1),2),27,27))));
st(5,if(eq(ld(1),0),45,if(eq(ld(1),1),40,if(eq(ld(1),2),36,32))));
st(6,1.5*exp(-pow((ld(0)-ld(2)/2)/1.2,2)));st(7,1);while(lte(ld(7),5),st(6,ld(6)+(exp(-pow((ld(0)-ld(2)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(3)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(4)*ld(7))/1.2,2))+exp(-pow((ld(0)-ld(5)*ld(7))/1.2,2)))/ld(7));st(7,ld(7)+1));
min(255,200*ld(6))',
minterpolate=fps=46.875:mi_mode=mci:scd=none:me_mode=bidir:me=esa:search_param=32,format=gray,crop=1:2049:16:0,
geq=lum='$STRIKE',lagfun=decay=0.88[m];
color=c=black:s=1x2049:r=46.875:d=$((D+8)),format=gray,geq=lum='255*mod((H-1-Y)*N/4,1)'[p];
[m][p]spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75" -t $D -c:a pcm_f32le $O.wav
./spec.sh $O.wav $O.png 1500 0 $D
