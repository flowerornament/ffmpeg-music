# test: single row lit, coherent phase, fullframe
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=400x4001:d=1:r=1,format=gray,geq=lum='255*eq(4000-Y,80)'[m];
color=c=black:s=400x4001:d=1:r=1,format=gray,geq=lum='255*mod((4000-Y)*X/4,1)'[p];
[m][p]spectrumsynth=sample_rate=44000:channels=1:slide=fullframe:scale=lin:win_func=hann:overlap=0.75" -t 10 "$@"
