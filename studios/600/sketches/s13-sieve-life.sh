# Life (64x64, one generation per phrase) seen through a Xenakis sieve on the partial index.
# A sieve on harmonics is a chord; turned 90 degrees, the same sieve on steps is a rhythm.
# Cell (col i, partial q) = 6x6 px: rows 6q-5..6q (pure partial at 6q, decaying below).
# Sieve here: (4,0) u (6,1) u (16,10). Plus a "pedal": kick strokes at q%4==0, phrase start.
SV="(eq(mod(ld(1),4),0)+eq(mod(ld(1),6),1)+eq(mod(ld(1),16),10))"
ROT="st(6,2*(512-Y));st(7,384-X/2);between(ld(6),0,383)*between(ld(7),0,383)*p(2*ld(6),512-ld(7))"
ffmpeg -hide_banner -y -filter_complex "
life=s=64x64:r=12800/98304:ratio=0.2:seed=7,trim=start_frame=200,setpts=PTS-STARTPTS,format=gray16,scale=384x384:flags=neighbor,pad=384:513:0:129,
 geq=lum='st(0,512-Y);st(1,ceil(ld(0)/6));st(2,6*ld(1)-ld(0));lte(ld(0),383)*gte(ld(1),1)*(
  min(1,$SV)*gt(p(X,Y),30000)*exp(-ld(2)/1.3)*5000
 +eq(mod(ld(1),4),0)*(exp(-ld(2)/2.2)*exp(-pow((X-7+0.8*ld(2))/1.3,2))+eq(ld(2),0)*0.5*exp(-X/10))*40000)',split[s1][s2];
[s2]scale=768x513:flags=bilinear,geq=lum='$ROT',crop=768:257:0:256[r];
nullsrc=s=384x513:r=12800/98304:d=40,format=gray16,geq=lum='65535*mod((512-Y)*(X+2)/4,1)'[pa];
nullsrc=s=768x257:r=12800/98304:d=40,format=gray16,geq=lum='65535*mod((256-Y)*(X+2)/4,1)'[pr];
[s1][pa]spectrumsynth=sample_rate=12800:slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1[A];
[r][pr]spectrumsynth=sample_rate=12800:slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1[B];
[A][B]amerge,aresample=48000" -t 38 "$@"
