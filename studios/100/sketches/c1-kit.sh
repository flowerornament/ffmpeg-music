# c1 kit: rhythm as Fourier series on a 0.5 Hz raster (sr 32768, N 65536 -> F = 1 bar of 2 s at 120 bpm)
# row k = k*0.5 Hz; comb spacing d = d pulses/bar; phase slope = timing; phase curvature = sweep.
W=32
K="(32767-Y)"
ADV="$K*X/4"
SS="spectrumsynth=sample_rate=32768:channels=1:slide=fullframe:scale=log:win_func=hann:overlap=0.75,aresample=48000"
img(){ echo "color=c=black:s=${W}x32768:d=1:r=1,format=gray,geq=lum='$1'"; }
# kick: d=4, band gaussian around 60 Hz, phase -c*ln(f)
KM="eq(mod($K,4),0)*gt($K,40)*max(0,200+20*log(exp(-pow(($K/2-60)/35,2)))/log(10))"
KP="255*mod($ADV-2*log($K/2+1),1)"
# snare: d=2 tau=1/4, band 180..7000 Hz, smooth random phase
SM="eq(mod($K,2),0)*between($K,360,14000)*(150-25*abs(log($K/1200)))"
SP="255*mod($ADV-$K/4+1.2*(sin($K/57)+sin($K/91+2)+sin($K/150+5)),1)"
# hats: d=4 tau=1/8 band 7..15 kHz
HM="eq(mod($K,4),0)*gt($K,14000)*120"
HP="255*mod($ADV-$K/8+0.3*sin($K/23),1)"
ffmpeg -hide_banner -y -filter_complex "
$(img "$KM")[km];$(img "$KP")[kp];[km][kp]$SS[k];
$(img "$SM")[sm];$(img "$SP")[sp];[sm][sp]$SS[s];
$(img "$HM")[hm];$(img "$HP")[hp];[hm][hp]$SS[h];
[k][s][h]amix=inputs=3:normalize=0,alimiter=limit=0.9" "$@"
