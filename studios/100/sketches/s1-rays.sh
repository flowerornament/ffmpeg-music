# s1 rays: a harmonic series whose fundamental row g(X) descends exponentially: every partial j
# is a ray j*g(X) through the origin = rigid transposition. Antialiased between rows.
W=700
K="(4095-mod(Y,4096))"
G="(48*pow(2,-X/$W*4.5))"
M="st(1,$K/$G);st(2,round(ld(1)));between(ld(2),1,16)*max(0,1-abs($K-ld(2)*$G))*(200-4*ld(2))"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x8192:d=1:r=1,format=gray,geq=lum='$M'[m];
color=c=black:s=${W}x8192:d=1:r=1,format=gray,geq=lum='255*mod($K*X/4+mod(sin($K*12.9898+gt(Y,4095)*7)*43758.5453,1),1)'[p];
[m][p]spectrumsynth=sample_rate=48000:channels=2:slide=fullframe:scale=log:win_func=hann:overlap=0.75,alimiter=limit=0.9" "$@"
