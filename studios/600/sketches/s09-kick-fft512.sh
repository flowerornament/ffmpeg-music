# Kick crispness test: the 90-degree reading at fft 512 (257 rows, 25 Hz bins, 10 ms cols).
# Rotated picture resampled: B time col u (0..767) = S row coordinate u/2; B bin v (0..256) = S col 2v.
SCORE="st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));
 eq(mod(ld(1),4),0)*between(ld(1),4,64)*(exp(-ld(2)/2.5)*exp(-pow((X-6+0.7*ld(2))/1.5,2))+eq(ld(2),0)*0.4*exp(-X/12))*40000
+eq(mod(ld(1),8),4)*lte(ld(2),4)*between(X,20,200)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2)/1.5)*7000
+eq(mod(ld(1),4),2)*lte(ld(2),1)*gte(X,220)*pow((X-220)/163,2)*9000"
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12800/98304:d=16,format=gray16,geq=lum='$SCORE',scale=768x513:flags=bilinear,
 geq=lum='st(6,2*(512-Y));st(7,384-X/2);between(ld(6),0,383)*between(ld(7),0,512)*p(2*ld(6),512-ld(7))',crop=768:257:0:256[r];
nullsrc=s=768x257:r=12800/98304:d=16,format=gray16,geq=lum='65535*mod((256-Y)*(X+2)/4,1)'[p];
[r][p]spectrumsynth=sample_rate=12800:slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1,aresample=48000" "$@"
