ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=512x513:r=48000/131072:d=11,format=gray,geq=lum='255*eq(mod(512-Y,24),0)*lt(512-Y,200)*gt(512-Y,0)'[img];
[img]split[a][b];[b]transpose=clock[t1];
nullsrc=s=512x513:r=48000/131072:d=11,format=gray,geq=lum=0,split[p1][p2];
[a][p1]spectrumsynth=sample_rate=48000:channels=1:slide=fullframe:scale=lin:overlap=0.75[o];
[t1]scale=512x513,setsar=1[t1s];[t1s][p2]spectrumsynth=sample_rate=48000:channels=1:slide=fullframe:scale=lin:overlap=0.75[r];
[o][r]amerge=inputs=2,volume=0.5" -t 10 "$@"
