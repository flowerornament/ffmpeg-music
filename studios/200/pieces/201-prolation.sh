#!/bin/sh
# bibdynamicoutcomeharvest  void
# bib  river  sleep  night  dark
# hahseasons  river  sleep  dark
# hah  river  sleep  night  dark
# hahtzarinamorninglantern  hush
# hah  river  sleep  night  dark
# hahdecided  river  sleep  dark
# impsmaller  river  sleep  dark
# bibdynamicoutcomeharvest  void
# bib  river  sleep  night  dark
# bibawkwardflowerswaiting  void
# hahseasons  river  sleep  dark
# hahtzarinamorninglantern  hush
# hah  river  sleep  night  dark
# hahdecided  river  sleep  dark
# peaeffortsegotist  sleep  dark
#
# 201 — PROLATION (for GSM 06.10 and sixteen typed lines)
#
# The sixteen lines above are the score AND the sound. Each is exactly 33 bytes
# ("# " + 30 letters + newline) = one GSM full-rate frame, so this file is a valid
# GSM bitstream from byte 10 to byte 538. In each line the 3-letter word after "# "
# is the throat (log-area ratios 3..8, the formant filter); then four 7-letter words
# are four subframes. The FIRST letter of a word is its pitch-lag (odd letters ring,
# even letters damp); the SECOND letter is loudness, a=ppp .. z=fff, space=rest.
# So "dynamic" is a hit, "  river" is silence, and the indentation is the rhythm.
#
# Every sample rate is a note. The gsm demuxer takes any -sample_rate, and speed is
# register: read the stanza at 1760 and it is a 1.45 s bar of drums (one line = one
# 16th, 165 bpm); twice as fast is an octave higher AND double time (Cowell's
# rhythmicon, Ockeghem's prolation canon). Read ONE line on a loop and it is a pitch,
# f = rate/160, coloured by its words. Upsampled with a 1-tap resampler, each slow
# voice also leaves spectral images at multiples of its own rate: 1760 = A6, so even
# the drums' "air" is in A.
#
#   rhythm   the stanza at 880 / 1760 / 2640 / 3520 / 7040 (1:2:3:4:8 on A).
#            1760 is doubled at 1762 on the right: the poem slowly phases against
#            itself (Reich, "Come Out"); 7040 is doubled at 7048.
#   harmony  single lines as tones, rate = 160 x frequency, just intonation on A=110:
#              i  A C E (110 132 165)     bVI F A C (176 132 110)
#              iv D F A (176 146.67 110)  V   E G# B (165 123.75 103.125)
#            "tzarina" sings the top, "awkward" the middle, "dynamic" the bass,
#            "seasons" the sub. Each voice's gate is a 4-bit mask over the 4 chords
#            (bit k of MASK = sounding in chord k), smoothed by a one-pole in aeval.
#   form     8 bars (11.636 s) per chord. tones alone -> groove -> canon -> the
#            groove drops out for one chord -> everything -> tones leave -> the poem.
ffmpeg -hide_banner -y \
 -stream_loop -1 -f gsm -sample_rate 880    -i "subfile,,start,10,end,538,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 1760   -i "subfile,,start,10,end,538,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 1762   -i "subfile,,start,10,end,538,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 2640   -i "subfile,,start,10,end,538,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 3520   -i "subfile,,start,10,end,538,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 7040   -i "subfile,,start,10,end,538,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 7048   -i "subfile,,start,10,end,538,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 26400  -i "subfile,,start,142,end,175,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 28160  -i "subfile,,start,142,end,175,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 21120  -i "subfile,,start,340,end,373,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 23467  -i "subfile,,start,340,end,373,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 19800  -i "subfile,,start,340,end,373,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 17600  -i "subfile,,start,10,end,43,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 16500  -i "subfile,,start,10,end,43,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 8800   -i "subfile,,start,76,end,109,,:$0" \
 -stream_loop -1 -f gsm -sample_rate 8250   -i "subfile,,start,76,end,109,,:$0" \
 -filter_complex "
 [0]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,aeval='st(0,ld(0)+0.0004*(between(t,46.55,116.36)+between(t,139.64,186.18)-ld(0)));val(0)*ld(0)*0.5',pan=stereo|c0=c0|c1=c0[r0];
 [1]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,aeval='st(0,ld(0)+0.002*(between(t,23.27,116.36)+between(t,128,214.5)-ld(0)));val(0)*ld(0)*0.4',pan=stereo|c0=c0|c1=0.3*c0[r1];
 [2]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,aeval='st(0,ld(0)+0.002*(between(t,23.27,116.36)+between(t,128,214.5)-ld(0)));val(0)*ld(0)*0.4',pan=stereo|c0=0.3*c0|c1=c0[r2];
 [3]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,aeval='st(0,ld(0)+0.0004*(between(t,69.82,186.18)-ld(0)));val(0)*ld(0)*0.22',pan=stereo|c0=c0|c1=0.5*c0[r3];
 [4]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,aeval='st(0,ld(0)+0.0004*(between(t,46.55,116.36)+between(t,128,186.18)-ld(0)));val(0)*ld(0)*0.2',pan=stereo|c0=0.5*c0|c1=c0[r4];
 [5]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,aformat=channel_layouts=mono,highpass=f=1500,aeval='st(0,ld(0)+0.0004*(between(t,69.82,116.36)+between(t,139.64,186.18)-ld(0)));val(0)*ld(0)*0.45',pan=stereo|c0=c0|c1=0.15*c0[h0];
 [6]asetpts=N/SR/TB,aresample=48000:filter_size=1:phase_shift=0,aformat=channel_layouts=mono,highpass=f=1500,aeval='st(0,ld(0)+0.0004*(between(t,69.82,116.36)+between(t,139.64,186.18)-ld(0)));val(0)*ld(0)*0.45',pan=stereo|c0=0.15*c0|c1=c0[h1];
 [7]asetpts=N/SR/TB,aresample=48000,aeval='st(0,ld(0)+0.0001*(mod(floor(9/pow(2,mod(floor(t/11.636364),4))),2)*lt(t,197.82)-ld(0)));val(0)*ld(0)*0.10',pan=stereo|c0=0.6*c0|c1=c0[t0];
 [8]asetpts=N/SR/TB,aresample=48000,aeval='st(0,ld(0)+0.0001*(mod(floor(6/pow(2,mod(floor(t/11.636364),4))),2)*lt(t,197.82)-ld(0)));val(0)*ld(0)*0.10',pan=stereo|c0=0.6*c0|c1=c0[t1];
 [9]asetpts=N/SR/TB,aresample=48000,aeval='st(0,ld(0)+0.0001*(mod(floor(3/pow(2,mod(floor(t/11.636364),4))),2)*lt(t,197.82)-ld(0)));val(0)*ld(0)*0.12',pan=stereo|c0=c0|c1=0.6*c0[t2];
 [10]asetpts=N/SR/TB,aresample=48000,aeval='st(0,ld(0)+0.0001*(mod(floor(4/pow(2,mod(floor(t/11.636364),4))),2)*lt(t,197.82)-ld(0)));val(0)*ld(0)*0.12',pan=stereo|c0=c0|c1=0.6*c0[t3];
 [11]asetpts=N/SR/TB,aresample=48000,aeval='st(0,ld(0)+0.0001*(mod(floor(8/pow(2,mod(floor(t/11.636364),4))),2)*lt(t,197.82)-ld(0)));val(0)*ld(0)*0.12',pan=stereo|c0=c0|c1=0.6*c0[t4];
 [12]asetpts=N/SR/TB,aresample=48000,aeval='st(0,ld(0)+0.0001*(mod(floor(7/pow(2,mod(floor(t/11.636364),4))),2)*lt(t,197.82)-ld(0)));val(0)*ld(0)*0.12'[t5];
 [13]asetpts=N/SR/TB,aresample=48000,aeval='st(0,ld(0)+0.0001*(mod(floor(8/pow(2,mod(floor(t/11.636364),4))),2)*lt(t,197.82)-ld(0)));val(0)*ld(0)*0.12'[t6];
 [14]asetpts=N/SR/TB,aresample=48000,aeval='st(0,ld(0)+0.0001*(mod(floor(7/pow(2,mod(floor(t/11.636364),4))),2)*between(t,11.64,197.82)-ld(0)));val(0)*ld(0)*0.4'[t7];
 [15]asetpts=N/SR/TB,aresample=48000,aeval='st(0,ld(0)+0.0001*(mod(floor(8/pow(2,mod(floor(t/11.636364),4))),2)*between(t,11.64,197.82)-ld(0)));val(0)*ld(0)*0.4'[t8];
 [t5][t6][t7][t8]amix=inputs=4:normalize=0,pan=stereo|c0=c0|c1=c0[low];
 [r0][r1][r2][r3][r4][h0][h1][t0][t1][t2][t3][t4][low]amix=inputs=13:normalize=0,
 highpass=f=28,highpass=f=28,volume=1.4,alimiter=level=0:limit=0.8:attack=2:release=60
 " -t 218.2 "$@"
