# One square score image S (256 cols x 256 bins, bin=8 Hz, col=15.625 ms) read two ways.
# Geometry: sr 48000, fft 6000 (3001 rows), overlap 0.875 -> hop 750. 8 cols = a 16th at 120 bpm,
# 8 bins = 64 Hz. So partial k of 64 Hz  <->  16th-step k. Frame = 256 cols = 2 bars.
# S: partials in MASK lit for the whole frame.  L = S as spectrum (a chord). R = S swapped
# (transpose=clock_flip: time<->frequency about the bottom-left origin) = a rhythm.
MASK=${MASK:-87376}   # bits 4,6,8,10,12,14,16 (C2 harmonics: C G C E G Bb C)
ffmpeg -hide_banner -y -filter_complex "
nullsrc=s=256x256:r=48000/192000:d=12,format=gray,geq=lum='60*eq(mod(255-Y,8),0)*mod(floor($MASK/pow(2,(255-Y)/8)),2)',split[s1][s2];
[s1]pad=256:3001:0:2745[a];
[s2]transpose=clock_flip,pad=256:3001:0:2745[b];
nullsrc=s=256x3001:r=48000/192000:d=12,format=gray,geq=lum='255*mod(X*(3000-Y)/8,1)',split[pa][pb];
[a][pa]spectrumsynth=sample_rate=48000:channels=1:slide=fullframe:scale=lin:overlap=0.875[A];
[b][pb]spectrumsynth=sample_rate=48000:channels=1:slide=fullframe:scale=lin:overlap=0.875[B];
[A][B]amerge,volume=0.5" "$@"
