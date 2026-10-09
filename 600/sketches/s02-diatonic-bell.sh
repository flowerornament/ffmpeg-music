# diatonic scale (C major, 2 octaves from C5) sustained -> spectrogram -> rotate 90 -> resynth.
# L = the chord, R = the chord turned on its side.
C=523.25
ffmpeg -hide_banner -y -filter_complex "
aevalsrc=s=48000:d=17:exprs='0.1*(sin(2*PI*$C*t)+sin(2*PI*$C*pow(2,2/12)*t)+sin(2*PI*$C*pow(2,4/12)*t)+sin(2*PI*$C*pow(2,5/12)*t)+sin(2*PI*$C*pow(2,7/12)*t)+sin(2*PI*$C*pow(2,9/12)*t)+sin(2*PI*$C*pow(2,11/12)*t))',asplit[dry][a];
[a]showspectrum=s=513x1025:slide=fullframe:scale=log:drange=${DR:-50}:fscale=log:start=$C:stop=2093:color=intensity:win_func=hann:overlap=0.75,format=gray,transpose=${ROT:-cclock},split[img][img2];
[img]geq=lum=128,format=gray[ph];
[img2][ph]spectrumsynth=sample_rate=48000:channels=1:slide=fullframe:scale=log:overlap=0.75[rot];[dry]volume=0.3[d2];[d2][rot]amerge" "$@"
