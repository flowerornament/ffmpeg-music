#!/bin/sh
# 208 — UNTRANSMITTED (coda)
#
# The record ends on the frame it is named after. In G.723.1 a one-byte frame whose
# first bits say "untransmitted" means: nothing was sent this time. In ASCII the
# letter o is such a frame. After a comfort-noise word it holds the noise; after
# speech it conceals, fading; before anything at all it is silence the decoder
# computes, 30 ms at a time.
#
# Eight voices say the first word of 202, "bool", at the overtone series of D
# (asetrate 262 x k/2), and each is given a different number of o's, so they leave
# one at a time from the top down, a farewell. When the last one has gone, a ninth
# decoder that has been receiving nothing for 74 seconds (617 o's) gets one speech
# frame, "the line is still open..", slowed to a low thud, and then 70 more o's:
# eight seconds of silence that is not the end of the file but a decoder still
# listening, told each 30 ms that nothing was sent.
ffmpeg -hide_banner -y \
 -f g723_1 -i "data:,boolooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" \
 -f g723_1 -i "data:,booloooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" \
 -f g723_1 -i "data:,booloooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" \
 -f g723_1 -i "data:,booloooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" \
 -f g723_1 -i "data:,booloooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" \
 -f g723_1 -i "data:,booloooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" \
 -f g723_1 -i "data:,booloooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" \
 -f g723_1 -i "data:,booloooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" \
 -f g723_1 -i "data:,ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooothe line is still open..oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo" \
 -filter_complex "
 [0]asetrate=1572,aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,volume=3.30,afade=t=out:st=16:d=6,asplit[a0][b00];[b00]afreqshift=shift=0.28[b0];
 [1]asetrate=1179,aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,volume=3.85,afade=t=out:st=24:d=6,asplit[a1][b10];[b10]afreqshift=shift=0.28[b1];
 [2]asetrate=917,aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,volume=4.40,afade=t=out:st=32:d=6,asplit[a2][b20];[b20]afreqshift=shift=0.28[b2];
 [3]asetrate=786,aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,volume=6.05,afade=t=out:st=40:d=6,asplit[a3][b30];[b30]afreqshift=shift=0.28[b3];
 [4]asetrate=655,aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,volume=6.60,afade=t=out:st=48:d=6,asplit[a4][b40];[b40]afreqshift=shift=0.28[b4];
 [5]asetrate=524,aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,volume=8.25,afade=t=out:st=56:d=6,asplit[a5][b50];[b50]afreqshift=shift=0.28[b5];
 [6]asetrate=393,aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,volume=8.80,afade=t=out:st=62:d=6,asplit[a6][b60];[b60]afreqshift=shift=0.28[b6];
 [7]asetrate=262,aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,volume=11.00,afade=t=out:st=68:d=6,asplit[a7][b70];[b70]anull[b7];
 [8]asetrate=2000,aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,volume=6,asplit[a8][b8];
 [a0][a1][a2][a3][a4][a5][a6][a7][a8]amix=inputs=9:normalize=0:duration=longest[L];
 [b0][b1][b2][b3][b4][b5][b6][b7][b8]amix=inputs=9:normalize=0:duration=longest[R];
 [L][R]amerge=inputs=2,alimiter=level=0:limit=0.8:attack=20:release=200[out]" -map "[out]" "$@"
