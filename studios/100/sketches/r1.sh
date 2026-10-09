# r1: I-IV-V-I in just intonation drawn as rows of a 4096-row raster (row k = k*48000/8192 Hz)
# each chord tone f carries harmonics j*f, j=1..6; brightness is dB (log scale)
K="(4095-mod(Y,4096))"
C="floor(X/96)"
R="if(eq(mod($C,4),1),4/3,if(eq(mod($C,4),2),3/2,1))"
U="(mod(X,96)/96)"
T="st(1,$K/(\$F*$R));st(2,round(ld(1)));lt(abs($K-ld(2)*\$F*$R),0.5)*between(ld(2),1,6)*(200-14*(ld(2)-1)-60*$U)"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=384x8192:d=1:r=1,format=gray,geq=lum='max(max(${T//\$F/96},${T//\$F/120}),max(${T//\$F/144},${T//\$F/24}))'[m];
color=c=black:s=384x8192:d=1:r=1,format=gray,geq=lum='255*mod($K*X/4+mod(sin($K*12.9898+gt(Y,4095)*7)*43758.5453,1),1)'[p];
[m][p]spectrumsynth=sample_rate=48000:channels=2:slide=fullframe:scale=log:win_func=hann:overlap=0.75,alimiter=limit=0.9" "$@"
