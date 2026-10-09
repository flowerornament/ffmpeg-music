# Conway's Life, 64x64 cells, one generation per 4-bar phrase (settled soup: skip 300 generations).
# Cell (i,j) = 6x6 pixels = 16th i (A time) x partial j. A: partial j sounds during 16th i.
# Turned: cell (i,j) -> step 64-j, band i*75 Hz. The same organism as arpeggiator and drum machine.
ROT="st(6,2*(512-Y));st(7,384-X/2);between(ld(6),0,383)*between(ld(7),0,383)*p(2*ld(6),512-ld(7))"
ffmpeg -hide_banner -y -filter_complex "
life=s=64x64:r=12800/98304:ratio=${RATIO:-0.2}:seed=${SEED:-7}:rule=${RULE:-B3/S23},trim=start_frame=300,setpts=PTS-STARTPTS,format=gray16,scale=384x384:flags=neighbor,pad=384:513:0:129,
 geq=lum='st(0,512-Y);st(1,mod(ld(0),6));st(2,mod(X,6));lt(ld(0),384)*gte(ld(0),6)*p(X,Y)/65535*exp(-ld(1)/1.2)*(0.6+0.4*exp(-ld(2)/2))*3000',split[s1][s2];
[s2]scale=768x513:flags=bilinear,geq=lum='$ROT',crop=768:257:0:256[r];
nullsrc=s=384x513:r=12800/98304:d=40,format=gray16,geq=lum='65535*mod((512-Y)*(X+2)/4,1)'[pa];
nullsrc=s=768x257:r=12800/98304:d=40,format=gray16,geq=lum='65535*mod((256-Y)*(X+2)/4,1)'[pr];
[s1][pa]spectrumsynth=sample_rate=12800:slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1[A];
[r][pr]spectrumsynth=sample_rate=12800:slide=fullframe:scale=lin:overlap=0.75:win_func=hann:channels=1[B];
[A][B]amerge,aresample=48000" -t 38 "$@"
