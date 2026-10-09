# Geometry G12/384: sr 12000, fft 1024 (513 rows), hop 256 (21.33 ms/col, 11.72 Hz/row).
# Frame = 384 cols = 4 bars of 16ths at 117.19 bpm (6 cols/16th). Partial p (row 6p) = 70.3125*p Hz.
# R(theta) = S rotated by theta about (192,192) in (col,row) space. At 90 deg: row k -> time 384-k,
# col c -> bin c.  So partial p <-> 16th-step 64-p, and when-in-the-phrase <-> how-high.
# This sketch: L = A (S as is), R = R(theta) with theta stepping 0,30,60,90 deg per phrase.
TH="PI/2*min(N,3)/3"
SC="st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));
 eq(mod(ld(1),4),0)*between(ld(1),4,64)*(exp(-ld(2)/2.5)*exp(-pow((X-6+0.7*ld(2))/1.5,2))+eq(ld(2),0)*0.4*exp(-X/12))*40000
+eq(mod(ld(1),8),4)*lte(ld(2),4)*between(X,20,200)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2)/1.5)*9000
+eq(mod(ld(1),4),2)*lte(ld(2),1)*gte(X,220)*pow((X-220)/163,2)*12000
+eq(ld(2),0)*lte(ld(1),52)*mod(floor(PART/pow(2,ld(1))),2)*1500
+eq(ld(2),0)*between(ld(1),1,2)*3000"
P1=$(( (1<<4)|(1<<5)|(1<<6)|(1<<8)|(1<<10)|(1<<12)|(1<<15)|(1<<20)|(1<<27)|(1<<33)|(1<<45) ))
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12000/98304:d=34,format=gray16,geq=lum='$(echo "$SC" | sed "s/PART/$P1/")',split[s1][s2];
[s2]geq=lum='st(5,$TH);st(6,(X-192)*cos(ld(5))+(320-Y)*sin(ld(5))+192);st(7,-(X-192)*sin(ld(5))+(320-Y)*cos(ld(5))+192);
 between(ld(6),0,383)*between(ld(7),0,512)*p(ld(6),512-ld(7))'[r];
nullsrc=s=384x513:r=12000/98304:d=34,format=gray16,geq=lum='65535*mod((512-Y)*(X+2)/4,1)',split[pa][pb];
[s1][pa]spectrumsynth=sample_rate=12000:channels=1:slide=fullframe:scale=lin:overlap=0.75:win_func=hann[A];
[r][pb]spectrumsynth=sample_rate=12000:channels=1:slide=fullframe:scale=lin:overlap=0.75:win_func=hann[B];
[A][B]amerge,aresample=48000" "$@"
