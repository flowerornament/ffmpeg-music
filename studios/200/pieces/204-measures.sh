#!/bin/sh
# the length of a line is the pitch it sings, so i measure:
# i set every line against the hum of the wires
# and a shorter line is a higher voice.
# short lines climb up higher
# a line of seventy letters hangs low in the room, a low string, a long
# cable under the floor, carrying the voice of one who was,
# a little lower than the one before, and older
# a slower wire, a lower darker one
# when the line runs on and on and on it gets so low that it is barely a voice at all, no
# more like the floor itself humming under a house, the C of the boiler
# and the plumbing, all of it under the one lamp in a hall,
# that does not quite light the stair at all
# then a line that is nearly as long leans on the door and asks to be let in...
# again, and the shorter lines lean too, a bit out of the ring,
# half a step over the edge of the old ring,
# and one that wants to come home now. 
#
# 204 — MEASURES (a chorale for DFPWM)
#
# DFPWM is a one-bit codec (it was made for radios inside a video game). Each byte is
# eight samples. Loop a line of L bytes at 48000 Hz and it sings 6000/L Hz: the
# length of a line is its pitch, and every line is an undertone of 6000 Hz. That
# 6000 Hz is also there in the sound - the byte clock, a high thin carrier - and it is
# the common harmonic of every note in the piece: the sky the chords hang from.
#
# So the poem above is typeset as harmony. Its four stanzas have line lengths
#   I   60 48 40 30   (100 125 150 200 Hz)      vi  72 60 48 36  (A minor)
#   IV  90 72 60 45   (F major)                 V7  80 64 45 40  (G B F G)
# and the lines are counted to the byte, newline included. Every line is a voice;
# when the harmony moves, one line crossfades into another, and where two chords
# share a note the pitch holds while the words under it change.
#
# The second half is the same poem read a third faster (asetrate 64000): every note,
# and the carrier, a perfect fourth higher (F major, carrier 8000 Hz). Then G7 - C.
# Each chord lasts 6 s; which chord sounds when is a 20-bit mask per chord (bit n =
# sounding in the n-th 6 s step), smoothed by a one-pole at 1 kHz.
ffmpeg -hide_banner -y \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,10,end,70,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,70,end,118,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,118,end,158,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,158,end,188,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,188,end,260,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,260,end,320,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,320,end,368,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,368,end,404,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,404,end,494,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,494,end,566,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,566,end,626,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,626,end,671,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,671,end,751,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,751,end,815,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,815,end,860,,:$0" \
 -stream_loop 3 -f dfpwm -sample_rate 48000 -i "subfile,,start,860,end,900,,:$0" \
 -filter_complex "
 aevalsrc=exprs='st(0,ld(0)+0.004*(mod(floor(786449/pow(2,floor(t/6))),2)-ld(0)))':s=1000:d=126,aresample=48000,asplit=5[Ac0a][Ac0b][Ac0c][Ac0d][Ac0e];
 aevalsrc=exprs='st(0,ld(0)+0.004*(mod(floor(34/pow(2,floor(t/6))),2)-ld(0)))':s=1000:d=126,aresample=48000,asplit=5[Ac1a][Ac1b][Ac1c][Ac1d][Ac1e];
 aevalsrc=exprs='st(0,ld(0)+0.004*(mod(floor(68/pow(2,floor(t/6))),2)-ld(0)))':s=1000:d=126,aresample=48000,asplit=5[Ac2a][Ac2b][Ac2c][Ac2d][Ac2e];
 aevalsrc=exprs='st(0,ld(0)+0.004*(mod(floor(131208/pow(2,floor(t/6))),2)-ld(0)))':s=1000:d=126,aresample=48000,asplit=5[Ac3a][Ac3b][Ac3c][Ac3d][Ac3e];
 aevalsrc=exprs='st(0,ld(0)+0.004*(mod(floor(69888/pow(2,floor(t/6))),2)-ld(0)))':s=1000:d=126,aresample=48000,asplit=5[Bc0a][Bc0b][Bc0c][Bc0d][Bc0e];
 aevalsrc=exprs='st(0,ld(0)+0.004*(mod(floor(8704/pow(2,floor(t/6))),2)-ld(0)))':s=1000:d=126,aresample=48000,asplit=5[Bc1a][Bc1b][Bc1c][Bc1d][Bc1e];
 aevalsrc=exprs='st(0,ld(0)+0.004*(mod(floor(17408/pow(2,floor(t/6))),2)-ld(0)))':s=1000:d=126,aresample=48000,asplit=5[Bc2a][Bc2b][Bc2c][Bc2d][Bc2e];
 aevalsrc=exprs='st(0,ld(0)+0.004*(mod(floor(34816/pow(2,floor(t/6))),2)-ld(0)))':s=1000:d=126,aresample=48000,asplit=5[Bc3a][Bc3b][Bc3c][Bc3d][Bc3e];
 [0]atrim=start_sample=1440:end_sample=1920,asetpts=N/SR/TB,aloop=loop=-1:size=480,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=3[x0a][x0b][x0l];
 [x0a][Ac0a]amultiply,pan=stereo|c0=0.55*c0|c1=0.55*c0[oA0];
 [x0b]asetrate=64000,aresample=48000[y0];[y0][Bc0a]amultiply,pan=stereo|c0=0.55*c0|c1=0.55*c0[oB0];
 [x0l]asplit[l0a][l0b];[l0a]asetrate=24000,aresample=48000,lowpass=f=900[z0a];[z0a][Ac0e]amultiply,pan=stereo|c0=0.9*c0|c1=0.9*c0[oL0];
 [l0b]asetrate=32000,aresample=48000,lowpass=f=1200[z0b];[z0b][Bc0e]amultiply,pan=stereo|c0=0.9*c0|c1=0.9*c0[oM0];
 [1]atrim=start_sample=1152:end_sample=1536,asetpts=N/SR/TB,aloop=loop=-1:size=384,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x1a][x1b];
 [x1a][Ac0b]amultiply,pan=stereo|c0=0.45*c0|c1=0.2025*c0[oA1];
 [x1b]asetrate=64000,aresample=48000[y1];[y1][Bc0b]amultiply,pan=stereo|c0=0.2025*c0|c1=0.45*c0[oB1];
 [2]atrim=start_sample=960:end_sample=1280,asetpts=N/SR/TB,aloop=loop=-1:size=320,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x2a][x2b];
 [x2a][Ac0c]amultiply,pan=stereo|c0=0.2025*c0|c1=0.45*c0[oA2];
 [x2b]asetrate=64000,aresample=48000[y2];[y2][Bc0c]amultiply,pan=stereo|c0=0.45*c0|c1=0.2025*c0[oB2];
 [3]atrim=start_sample=720:end_sample=960,asetpts=N/SR/TB,aloop=loop=-1:size=240,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x3a][x3b];
 [x3a][Ac0d]amultiply,pan=stereo|c0=0.32000000000000006*c0|c1=0.32000000000000006*c0[oA3];
 [x3b]asetrate=64000,aresample=48000[y3];[y3][Bc0d]amultiply,pan=stereo|c0=0.32000000000000006*c0|c1=0.32000000000000006*c0[oB3];
 [4]atrim=start_sample=1728:end_sample=2304,asetpts=N/SR/TB,aloop=loop=-1:size=576,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=3[x4a][x4b][x4l];
 [x4a][Ac1a]amultiply,pan=stereo|c0=0.55*c0|c1=0.55*c0[oA4];
 [x4b]asetrate=64000,aresample=48000[y4];[y4][Bc1a]amultiply,pan=stereo|c0=0.55*c0|c1=0.55*c0[oB4];
 [x4l]asplit[l4a][l4b];[l4a]asetrate=24000,aresample=48000,lowpass=f=900[z4a];[z4a][Ac1e]amultiply,pan=stereo|c0=0.9*c0|c1=0.9*c0[oL4];
 [l4b]asetrate=32000,aresample=48000,lowpass=f=1200[z4b];[z4b][Bc1e]amultiply,pan=stereo|c0=0.9*c0|c1=0.9*c0[oM4];
 [5]atrim=start_sample=1440:end_sample=1920,asetpts=N/SR/TB,aloop=loop=-1:size=480,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x5a][x5b];
 [x5a][Ac1b]amultiply,pan=stereo|c0=0.45*c0|c1=0.2025*c0[oA5];
 [x5b]asetrate=64000,aresample=48000[y5];[y5][Bc1b]amultiply,pan=stereo|c0=0.2025*c0|c1=0.45*c0[oB5];
 [6]atrim=start_sample=1152:end_sample=1536,asetpts=N/SR/TB,aloop=loop=-1:size=384,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x6a][x6b];
 [x6a][Ac1c]amultiply,pan=stereo|c0=0.2025*c0|c1=0.45*c0[oA6];
 [x6b]asetrate=64000,aresample=48000[y6];[y6][Bc1c]amultiply,pan=stereo|c0=0.45*c0|c1=0.2025*c0[oB6];
 [7]atrim=start_sample=864:end_sample=1152,asetpts=N/SR/TB,aloop=loop=-1:size=288,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x7a][x7b];
 [x7a][Ac1d]amultiply,pan=stereo|c0=0.32000000000000006*c0|c1=0.32000000000000006*c0[oA7];
 [x7b]asetrate=64000,aresample=48000[y7];[y7][Bc1d]amultiply,pan=stereo|c0=0.32000000000000006*c0|c1=0.32000000000000006*c0[oB7];
 [8]atrim=start_sample=2160:end_sample=2880,asetpts=N/SR/TB,aloop=loop=-1:size=720,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=3[x8a][x8b][x8l];
 [x8a][Ac2a]amultiply,pan=stereo|c0=0.55*c0|c1=0.55*c0[oA8];
 [x8b]asetrate=64000,aresample=48000[y8];[y8][Bc2a]amultiply,pan=stereo|c0=0.55*c0|c1=0.55*c0[oB8];
 [x8l]asplit[l8a][l8b];[l8a]asetrate=24000,aresample=48000,lowpass=f=900[z8a];[z8a][Ac2e]amultiply,pan=stereo|c0=0.9*c0|c1=0.9*c0[oL8];
 [l8b]asetrate=32000,aresample=48000,lowpass=f=1200[z8b];[z8b][Bc2e]amultiply,pan=stereo|c0=0.9*c0|c1=0.9*c0[oM8];
 [9]atrim=start_sample=1728:end_sample=2304,asetpts=N/SR/TB,aloop=loop=-1:size=576,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x9a][x9b];
 [x9a][Ac2b]amultiply,pan=stereo|c0=0.45*c0|c1=0.2025*c0[oA9];
 [x9b]asetrate=64000,aresample=48000[y9];[y9][Bc2b]amultiply,pan=stereo|c0=0.2025*c0|c1=0.45*c0[oB9];
 [10]atrim=start_sample=1440:end_sample=1920,asetpts=N/SR/TB,aloop=loop=-1:size=480,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x10a][x10b];
 [x10a][Ac2c]amultiply,pan=stereo|c0=0.2025*c0|c1=0.45*c0[oA10];
 [x10b]asetrate=64000,aresample=48000[y10];[y10][Bc2c]amultiply,pan=stereo|c0=0.45*c0|c1=0.2025*c0[oB10];
 [11]atrim=start_sample=1080:end_sample=1440,asetpts=N/SR/TB,aloop=loop=-1:size=360,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x11a][x11b];
 [x11a][Ac2d]amultiply,pan=stereo|c0=0.32000000000000006*c0|c1=0.32000000000000006*c0[oA11];
 [x11b]asetrate=64000,aresample=48000[y11];[y11][Bc2d]amultiply,pan=stereo|c0=0.32000000000000006*c0|c1=0.32000000000000006*c0[oB11];
 [12]atrim=start_sample=1920:end_sample=2560,asetpts=N/SR/TB,aloop=loop=-1:size=640,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=3[x12a][x12b][x12l];
 [x12a][Ac3a]amultiply,pan=stereo|c0=0.55*c0|c1=0.55*c0[oA12];
 [x12b]asetrate=64000,aresample=48000[y12];[y12][Bc3a]amultiply,pan=stereo|c0=0.55*c0|c1=0.55*c0[oB12];
 [x12l]asplit[l12a][l12b];[l12a]asetrate=24000,aresample=48000,lowpass=f=900[z12a];[z12a][Ac3e]amultiply,pan=stereo|c0=0.9*c0|c1=0.9*c0[oL12];
 [l12b]asetrate=32000,aresample=48000,lowpass=f=1200[z12b];[z12b][Bc3e]amultiply,pan=stereo|c0=0.9*c0|c1=0.9*c0[oM12];
 [13]atrim=start_sample=1536:end_sample=2048,asetpts=N/SR/TB,aloop=loop=-1:size=512,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x13a][x13b];
 [x13a][Ac3b]amultiply,pan=stereo|c0=0.45*c0|c1=0.2025*c0[oA13];
 [x13b]asetrate=64000,aresample=48000[y13];[y13][Bc3b]amultiply,pan=stereo|c0=0.2025*c0|c1=0.45*c0[oB13];
 [14]atrim=start_sample=1080:end_sample=1440,asetpts=N/SR/TB,aloop=loop=-1:size=360,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x14a][x14b];
 [x14a][Ac3c]amultiply,pan=stereo|c0=0.2025*c0|c1=0.45*c0[oA14];
 [x14b]asetrate=64000,aresample=48000[y14];[y14][Bc3c]amultiply,pan=stereo|c0=0.45*c0|c1=0.2025*c0[oB14];
 [15]atrim=start_sample=960:end_sample=1280,asetpts=N/SR/TB,aloop=loop=-1:size=320,atrim=end=170,aformat=channel_layouts=mono,highpass=f=25,asplit=2[x15a][x15b];
 [x15a][Ac3d]amultiply,pan=stereo|c0=0.32000000000000006*c0|c1=0.32000000000000006*c0[oA15];
 [x15b]asetrate=64000,aresample=48000[y15];[y15][Bc3d]amultiply,pan=stereo|c0=0.32000000000000006*c0|c1=0.32000000000000006*c0[oB15];
 [oA0][oB0][oL0][oM0][oA1][oB1][oA2][oB2][oA3][oB3][oA4][oB4][oL4][oM4][oA5][oB5][oA6][oB6][oA7][oB7][oA8][oB8][oL8][oM8][oA9][oB9][oA10][oB10][oA11][oB11][oA12][oB12][oL12][oM12][oA13][oB13][oA14][oB14][oA15][oB15]amix=inputs=40:normalize=0,volume=0.7,alimiter=level=0:limit=0.8:attack=5:release=100,afade=t=out:st=114:d=6[out]" -map "[out]" -t 120 "$@"
