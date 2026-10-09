# s2 parallels: one chord shape (4:5:6:7 at multiplier 16 -> rows 64 80 96 112) translated by a
# constant row offset s per bar: 0,16,8,24,4,... addition changes chord quality, not register.
W=700
K="(4095-mod(Y,4096))"
S="(16*mod(floor(X/64)*5,7))"
U="(mod(X,64)/64)"
V="st(3,$K-$S);(eq(ld(3),64)+eq(ld(3),80)+eq(ld(3),96)+eq(ld(3),112)+0.8*eq(ld(3),16)+0.6*eq(ld(3),32))*(196-40*$U)"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x8192:d=1:r=1,format=gray,geq=lum='$V'[m];
color=c=black:s=${W}x8192:d=1:r=1,format=gray,geq=lum='255*mod($K*X/4+mod(sin($K*12.9898+gt(Y,4095)*7)*43758.5453,1),1)'[p];
[m][p]spectrumsynth=sample_rate=48000:channels=2:slide=fullframe:scale=log:win_func=hann:overlap=0.75,alimiter=limit=0.9" "$@"
