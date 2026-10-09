#!/bin/sh
# 407 — Colophon  (Organology VII)
#
# the last organ is the score.
# this file reads itself aloud, seven letters a second:
# every letter is a note, every space a breath,
# every new line a bar, struck by the cosine kick,
# and the line count turns the chords: i, six, three, seven.
# digits are hats, signs are clicks, capitals sing higher.
# so this verse is a melody i wrote by choosing words,
# and when the verse ends, the machine part of the page
# plays its dollars, brackets and quotes as a drum solo.
# change one word and the music changes with it.
# (the verse is bytes VS..VE of this file; the machine part, read fast, is VE..end.
#  if you edit the verse, recount: VS = first byte of "the last", VE = end of this line)
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
mov() { echo "amovie='subfile,,start,$(($1)),end,$(($1+$2)),,\\:$A':f=$3:format_opts='sample_rate=$4\\:ch_layout=mono'"; }
ZOH="aresample=48000:filter_size=1:phase_shift=0"
VS=49; VE=745
# bus RATE DECAY : 5 control channels from a byte stream read at RATE chars/s
#   9 byte, 8 letter index (a=0, case folded) or -1, 7 newline count, 6 char onset
bus() {
P="st(9,round((val(0)+1)*128));st(6,eq(mod(n,48000/$1),0));st(8,if(between(ld(9),97,122),ld(9)-97,if(between(ld(9),65,90),ld(9)-65,-1)))"
L="st(7,ld(7)+ld(6)*eq(ld(9),10))"; ROOT="mod(floor(6250/pow(10,mod(ld(7),4))),10)"
SEM="(floor((12*(DEG+5)+5)/7)-9)"
M="($(echo $SEM | sed "s|DEG|($ROOT+mod(ld(8),15))|")+12*between(ld(9),65,90))"
BS=$(echo $SEM | sed "s|DEG|($ROOT)|")
E="exp(-mod(t*$1,1)*$2)"
echo "aeval=exprs='$P;$L;gte(ld(8),0)*$E*(1+between(ld(9),65,90))*lt(mod(t*220*pow(2,$M/12),1),220*pow(2,$M/12)/48000)|$P;$L;ld(6)*eq(ld(9),10)|$P;$L;eq(ld(9),10)*exp(-mod(t*$1,1)*0.8)*lt(mod(t*55*pow(2,$BS/12),1),55*pow(2,$BS/12)/48000)|$P;ld(6)*between(ld(9),48,57)|$P;ld(6)*not(between(ld(9),48,57))*not(eq(ld(9),10))*not(eq(ld(9),32))*lt(ld(8),0)*(0.3+(ld(9)-33)/60)':channel_layout=5.0"
}
ffmpeg -hide_banner -y \
 -f u8 -ar 7  -ac 1 -i "subfile,,start,$VS,end,$VE,,:$0" \
 -f u8 -ar 48 -ac 1 -i "subfile,,start,$VE,,:$0" -filter_complex "
[0]$ZOH,aformat=channel_layouts=mono,$(bus 7 6),apad=pad_dur=1.5[vb];
[1]$ZOH,aformat=channel_layouts=mono,$(bus 48 40)[mb];
[vb][mb]concat=n=2:v=0:a=1,channelsplit=channel_layout=5.0[mt][kt][bt][ht][ct];

$(mov 0xc0a640 2560 f32le 48000),highpass=f=30[qir];
[mt][qir]afir=irnorm=2,volume=2.2,lowpass=f=5000,asplit[m1][m2];[m2]adelay=17[m2d];[m1][m2d]join=inputs=2:channel_layout=stereo[MEL];

$(mov 0xcc09f0 1024 s16le 76800),aloop=0:512,aresample=48000[k1];
$(mov 0xcc09f0 1024 s16le 48640),aloop=0:512,aresample=48000[k2];
$(mov 0xcc09f0 1024 s16le 28160),aloop=1:512,aresample=48000[k3];
[k1][k2][k3]concat=n=3:v=0:a=1,afade=t=out:st=0.03:d=0.08:curve=exp[kir];
[kt][kir]afir=irnorm=-1,volume=0.8,pan=stereo|c0=c0|c1=c0[K];

$(mov 0xcc09f0 1024 s16le 48000),aloop=0:512,aresample=48000[bir];
[bt][bir]afir=irnorm=2,volume=1.4,lowpass=f=700,pan=stereo|c0=c0|c1=c0[B];

$(mov 0x2f42c4 2400 u8 48000),highpass=f=7000,afade=t=out:st=0:d=0.04:curve=exp[hir];
[ht][hir]afir=irnorm=2,volume=2.5,pan=stereo|c0=0.5*c0|c1=c0[H];
$(mov 0xdc2c40 544 f32le 48000),highpass=f=200[cir];
[ct][cir]afir=irnorm=2,volume=1.6,highpass=f=300,pan=stereo|c0=c0|c1=0.6*c0[C];

[MEL][C]amix=inputs=2:normalize=0,asplit[dry][w0];
$(mov 0x9a04 96000 u8 48000),highpass=f=250,lowpass=f=5000,afade=t=out:st=0:d=2:curve=exp,asplit[i1][i2];
[i2]adelay=7[i2d];[i1][i2d]amerge[rir];[w0][rir]afir=irnorm=2,volume=0.35[wet];
[dry][wet][K][B][H]amix=inputs=5:normalize=0,volume=2.6,acompressor=threshold=0.3:ratio=2.5:attack=5:release=120,
 alimiter=limit=0.8:level=0,apad=pad_dur=2.5
" "$@"
