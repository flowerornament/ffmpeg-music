# Geometry "G12": spectrumsynth at 12 kHz, fft 1024 (513 rows), overlap .75 -> hop 256.
#   1 column = 21.333 ms, 1 row = 11.71875 Hz.  6 cols = a 16th at 117.19 bpm; 6 rows = 70.3125 Hz.
#   => partial k of 70.3125 Hz  <->  16th-step k.  Frame = 192 cols = 2 bars; score square 192x192.
# Universal phase image P = frac(k*(x+2)/4): coherent sustained tones AND centred clicks.
# L = S read as spectrum (chord), R = S with time and frequency swapped (rhythm).
MASK=${MASK:-87376}
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=192x192:r=12000/49152:d=12,format=gray16,geq=lum='2000*eq(mod(191-Y,6),0)*mod(floor($MASK/pow(2,(191-Y)/6)),2)',split[s1][s2];
[s1]pad=192:513:0:321[a];
[s2]transpose=clock_flip,pad=192:513:0:321[b];
nullsrc=s=192x513:r=12000/49152:d=12,format=gray16,geq=lum='65535*mod((512-Y)*(X+2)/4,1)',split[pa][pb];
[a][pa]spectrumsynth=sample_rate=12000:channels=1:slide=fullframe:scale=lin:overlap=0.75:win_func=hann[A];
[b][pb]spectrumsynth=sample_rate=12000:channels=1:slide=fullframe:scale=lin:overlap=0.75:win_func=hann[B];
[A][B]amerge,aresample=48000" "$@"
