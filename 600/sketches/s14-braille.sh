# Braille as a drum machine. The text is drawn with Apple Braille Pinpoint (raised dots are full,
# absent dots are faint "pinpoints" -> ghost notes). One braille cell = one beat; dot column 0 on the
# beat, column 1 on the "and"; dot rows: top = hat, middle = snare, bottom = kick (in the TURNED
# reading). One line of 16 cells = one 4-bar phrase.
PH=7.68
M="floor(T/$PH+0.01)"
TXT="⠞⠓⠑⠀⠃⠑⠁⠞⠀⠊⠎⠀⠁⠀⠉⠓
⠕⠗⠙⠀⠞⠥⠗⠝⠑⠙⠀⠕⠝⠀⠊⠞
⠎⠀⠎⠊⠙⠑⠲⠀⠗⠑⠁⠙⠀⠊⠞⠀
⠺⠊⠞⠓⠀⠽⠕⠥⠗⠀⠃⠕⠙⠽⠲⠀"
DOT="(p(ld(5)-1,ld(6))+p(ld(5),ld(6))+p(ld(5)+1,ld(6))+p(ld(5),ld(6)-1)+p(ld(5),ld(6)+1))/65535"
SC="st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));st(3,64-ld(1));st(4,floor(ld(3)/4));
 st(5,5+16.4*ld(4)+3*mod(ld(3),4));st(6,1+27*mod($M,4));
 lte(ld(0),383)*gte(ld(1),1)*not(mod(ld(3),2))*(
  st(7,$DOT);st(6,ld(6)+6);st(8,$DOT);st(6,ld(6)+6);st(9,$DOT);
  if(gt(ld(9),2),1,0.12*gt(ld(9),0.3))*(exp(-ld(2)/2.2)*exp(-pow((X-7+0.8*ld(2))/1.3,2))+eq(ld(2),0)*0.5*exp(-X/10))*40000
 +if(gt(ld(8),2),1,0.12*gt(ld(8),0.3))*lte(ld(2),3)*between(X,50,220)*mod(sin(X*12.9898+ld(0)*78.233)*43758.5453,1)*exp(-ld(2)/1.3)*12000
 +if(gt(ld(7),2),1,0.12*gt(ld(7),0.3))*lte(ld(2),1)*gte(X,280)*pow((X-280)/103,2)*14000)"
ROT="st(6,2*(512-Y));st(7,384-X/2);between(ld(6),0,383)*between(ld(7),0,383)*p(2*ld(6),512-ld(7))"
ffmpeg -hide_banner -y -filter_complex "
color=black:s=384x513:r=12800/98304:d=32,format=gray,
 drawtext=fontfile='/System/Library/Fonts/Apple Braille Pinpoint 6 Dot.ttf':text='$TXT':fontsize=24:fontcolor=white:x=0:y=0,
 format=gray16,geq=lum='$SC',split[s1][s2];
[s2]scale=768x513:flags=bilinear,geq=lum='$ROT',crop=768:257:0:256[r];
nullsrc=s=384x513:r=12800/98304:d=32,format=gray16,geq=lum='65535*mod((512-Y)*(X+2)/4,1)'[pa];
nullsrc=s=768x257:r=12800/98304:d=32,format=gray16,geq=lum='65535*mod((256-Y)*(X+2)/4,1)'[pr];
[s1][pa]spectrumsynth=sample_rate=12800:slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1[A];
[r][pr]spectrumsynth=sample_rate=12800:slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1[B];
[A][B]amerge,aresample=48000" -t 31 "$@"
