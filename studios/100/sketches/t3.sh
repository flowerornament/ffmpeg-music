# single row, magnitude 60/255, 2 frames per... timing test, FFT 8192 (H=4097) at 48k
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=100x4097:d=1:r=1,format=gray,geq=lum='60*eq(4096-Y,75)'[m];
color=c=black:s=100x4097:d=1:r=1,format=gray,geq=lum='255*mod((4096-Y)*X/4,1)'[p];
[m][p]spectrumsynth=sample_rate=48000:channels=1:slide=fullframe:scale=lin:win_func=hann:overlap=0.75" "$@"
