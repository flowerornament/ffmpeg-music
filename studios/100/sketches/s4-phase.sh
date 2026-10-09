# s4 phase as timbre: same chord (rows 48 60 72 84 96 + 24) in 4 sections; phase image is
# coherent / random per column / cellular automaton / zoneplate.
W=700
K="(4095-mod(Y,4096))"
V="(eq($K,24)+eq($K,48)+eq($K,60)+eq($K,72)+eq($K,84)+eq($K,96)+eq($K,120)+eq($K,144))*190"
ffmpeg -hide_banner -y -filter_complex "
color=c=black:s=${W}x8192:d=1:r=1,format=gray,geq=lum='$V'[m];
color=c=black:s=${W}x8192:d=1:r=1,format=gray,geq=lum='255*mod($K*X/4+mod(sin($K*12.9898)*43758.5453,1),1)*lt(X,175)+random(1)*255*between(X,175,349)+255*mod($K*X/4+0.1*random(2),1)*between(X,350,524)+255*mod($K*X/4*1.01,1)*gte(X,525)'[p];
[m][p]spectrumsynth=sample_rate=48000:channels=2:slide=fullframe:scale=log:win_func=hann:overlap=0.75,alimiter=limit=0.9" "$@"
