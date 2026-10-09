# The groove picture (601 score, 90 degree reading) under the other area-preserving maps of the
# time-frequency plane. Phrase 0: plain. 1: shear b=0.06 (high frequencies later: swing / chirps).
# 2: shear b=-0.06. 3: squeeze s=2 about the phrase start (half time, an octave down).
# 4: squeeze glide s 1->2 inside the phrase (tape stop). 5: squeeze s=0.5 (double time, octave up).
PH=7.68
M="floor(T/$PH+0.01)"
TRI=282578801202544
SCORE="st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));
 st(3,1);st(4,ld(1)/ld(3));
 eq(mod(ld(1),4),0)*between(ld(1),4,64)*(exp(-ld(2)/2.2)*exp(-pow((X-7+0.8*ld(2))/1.3,2))+eq(ld(2),0)*0.5*exp(-X/10))*40000
+eq(mod(ld(1),8),4)*lte(ld(2),3)*between(X,40,220)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2)/1.4)*8000
+eq(mod(ld(1),4),2)*lte(ld(2),1)*gte(X,250)*pow((X-250)/133,2)*12000
+eq(ld(2),0)*eq(ld(4),floor(ld(4)))*lte(ld(4),48)*mod(floor($TRI/pow(2,ld(4))),2)*(0.35+0.65*exp(-X/120))*2000
+eq(ld(2),0)*between(ld(1),1,2)*3000"
B="if(eq($M,1),0.06,if(eq($M,2),-0.06,0))"
SQ="if(eq($M,3),2,if(eq($M,4),1+X/768,if(eq($M,5),0.5,1)))"
MAP="st(8,X/2);st(9,2*(512-Y));st(8,ld(8)-($B)*ld(9));st(5,$SQ);st(8,ld(8)/ld(5));st(9,ld(9)*ld(5));
 st(6,ld(9));st(7,384-ld(8));
 between(ld(6),0,383)*between(ld(7),0,383)*p(2*ld(6),512-ld(7))"
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=384x513:r=12800/98304:d=46.08,format=gray16,geq=lum='$SCORE',scale=768x513:flags=bilinear,geq=lum='$MAP',crop=768:257:0:256[r];
nullsrc=s=768x257:r=12800/98304:d=46.08,format=gray16,geq=lum='65535*mod((256-Y)*(X+2)/4,1)'[p];
[r][p]spectrumsynth=sample_rate=12800:slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1,aresample=48000" "$@"
