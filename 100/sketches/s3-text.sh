# s3 text: the word drawn by drawtext into the low 400 rows of the raster becomes a chord-cloud.
W=700
K="(4095-mod(Y,4096))"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x4096:d=1:r=1,format=gray,drawtext=text='harmony':fontsize=200:fontcolor=white:x=40:y=4096-300,split[a][b];[a][b]vstack,geq=lum='p(X,Y)*0.78'[m];
color=c=black:s=${W}x8192:d=1:r=1,format=gray,geq=lum='255*mod($K*X/4+mod(sin($K*12.9898+gt(Y,4095)*7)*43758.5453,1),1)'[p];
[m][p]spectrumsynth=sample_rate=48000:channels=2:slide=fullframe:scale=log:win_func=hann:overlap=0.75,alimiter=limit=0.9" "$@"
