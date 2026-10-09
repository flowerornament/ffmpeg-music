#!/bin/bash
# pedal.sh out qp "kf expr" dur : arpeggio one voice per 16th through x264 (left) and mjpeg (right)
O=$1; QP=$2; KF=$3; D=${4:-16}
ARP="st(0,H-1-Y);st(9,N);st(8,mod(floor(N/16),4));
st(1,if(eq(ld(8),0),24,if(eq(ld(8),1),20,if(eq(ld(8),2),16,18))));
st(2,mod(3*ld(9),5));st(3,ld(1)*if(eq(ld(2),0),1,if(eq(ld(2),1),1.25,if(eq(ld(2),2),1.5,if(eq(ld(2),3),2,2.5))))*if(mod(floor(ld(9)/5),2),2,1));
st(6,0);st(7,1);while(lte(ld(7),6),st(6,ld(6)+exp(-pow((ld(0)-ld(3)*ld(7))/1.0,2))/ld(7));st(7,ld(7)+1));min(255,200*ld(6))"
ffmpeg -hide_banner -loglevel error -y -filter_complex "color=c=black:s=32x2048:r=46.875/6:d=$((D+1)),format=gray,geq=lum='$ARP',fps=46.875,split[v1][v2];[v1]format=yuv420p[x];[v2]format=yuvj420p[j]" \
 -map "[x]" -c:v libx264 -qp $QP -bf 0 -sc_threshold 0 -g 100000 -force_key_frames "$KF" -f null - \
 -map "[j]" -c:v mjpeg -q:v 20 -f null - -dec 0:0 -dec 1:0 -filter_complex "
[dec:0]fps=46.875,format=gray,crop=1:2048:16:0,pad=1:2049:0:1,geq=lum='p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*gt(p(X,Y),5)*0.1'[mL];
[dec:1]fps=46.875,format=gray,crop=1:2048:16:0,pad=1:2049:0:1,geq=lum='p(X,Y)*gt(p(X,Y),p(X,Y-1))*gte(p(X,Y),p(X,Y+1))*gt(p(X,Y),5)*0.1'[mR];
color=c=black:s=1x2049:r=46.875:d=$((D+1)),format=gray,geq=lum='255*mod((H-1-Y)*N/4+sin((H-1-Y)*12.9898)*43758.5453,1)',split[pL][pR];
[mL][pL]spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75,aformat=channel_layouts=mono[l];[mR][pR]spectrumsynth=sample_rate=48000:channels=1:slide=scroll:scale=lin:win_func=hann:overlap=0.75,aformat=channel_layouts=mono[r];
[l][r]join=inputs=2:channel_layout=stereo[o]" -map "[o]" -t $D -c:a pcm_f32le $O.wav
ffmpeg -hide_banner -loglevel error -y -i $O.wav -af "pan=mono|c0=c0" ${O}L.wav; ffmpeg -hide_banner -loglevel error -y -i $O.wav -af "pan=mono|c0=c1" ${O}R.wav
./spec.sh ${O}L.wav ${O}L.png 2000 0 6 sqrt; ./spec.sh ${O}R.wav ${O}R.png 2000 0 6 sqrt; ffmpeg -hide_banner -loglevel error -y -i ${O}L.png -i ${O}R.png -filter_complex vstack $O.png
