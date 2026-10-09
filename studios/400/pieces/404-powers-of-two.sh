#!/bin/sh
# 404 — Powers of Two  (Organology IV)
#
# One reading convention, sixteen speeds. The AAC spectral codebooks (1241 code lengths,
# libavcodec 0xc0d558) drive the pitch of a pulsar oscillator: code length -> aeolian degree
# above A3, phase-accumulated, impulse train convolved with the CELT window. Nothing else
# changes except how fast the table is read: section k reads it at 1241 * 2^k / 256 bytes/s.
#   k=0..2   4.8 .. 19 notes/s   a melody, then a trill (Barbieri's ~12 Hz fusion line)
#   k=3..5   39 .. 155 notes/s   grains; at k=5 the whole table passes in 8 s, so the eleven
#                                 codebooks are heard as eleven colours of one gesture
#   k=6..11  loop every 4 s .. 8 Hz   the table's repetition becomes metre (a kick marks it
#                                 while it is between 0.5 and 2 Hz)
#   k=12..15 16 Hz, then 27.5, 55, 110 Hz: the loop crosses into pitch and lands on A: the melody is now the FM
#                                 modulator of a tone whose fundamental is the read rate / 1241
# Each layer is its own reading (declared -ar), crossfaded like Eames's Powers of Ten.
# Under it: a pedal A from the g723.1 cosine table. Room: aac_decode_frame's code.
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
B=$((0xc0d558)); N=1241
tab() { echo "subfile,,start,$(($1)),end,$(($1+$2)),,:$A"; }
mov() { echo "amovie='subfile,,start,$(($1)),end,$(($1+$2)),,\\:$A':f=$3:format_opts='sample_rate=$4\\:ch_layout=mono'"; }
ZOH="aresample=48000:filter_size=1:phase_shift=0"
# layer K START LEN : table read at N*2^K/256 Hz, pitch-mapped pulsar, faded, delayed to START
# (declared rate must be an integer: N*2^K/256 rounded; drift is part of it)
OSC="st(9,round((val(0)+1)*128));st(1,floor((12*(ld(9)+1)+5)/7)-2);st(2,220*pow(2,ld(1)/12)/48000);st(0,ld(0)+ld(2));st(3,gte(ld(0),1));st(0,ld(0)-ld(3));st(4,ld(3)*ld(0)/ld(2));st(5,ld(8)+ld(3)*(1-ld(4)));st(8,ld(4));ld(5)"
layer() { echo "[$1]aloop=-1:$N,$ZOH,atrim=0:$3,aeval='$OSC',afade=t=in:d=4:curve=hsin,afade=t=out:st=$(($3-5)):d=5:curve=hsin,adelay=$(($2*1000)):all=1"; }
ffmpeg -hide_banner -y \
 -f u8 -ar 5     -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 10    -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 19    -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 39    -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 78    -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 155   -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 310   -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 621   -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 1241  -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 2482  -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 4964  -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 9928  -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 19856 -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 34128 -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 68255 -ac 1 -i "$(tab $B $N)" \
 -f u8 -ar 136510 -ac 1 -i "$(tab $B $N)" \
 -filter_complex "
$(layer 0 0 24)[l0];$(layer 1 18 20)[l1];$(layer 2 32 18)[l2];$(layer 3 44 18)[l3];
$(layer 4 56 18)[l4];$(layer 5 68 22)[l5];$(layer 6 84 20)[l6];$(layer 7 98 20)[l7];
$(layer 8 112 18)[l8];$(layer 9 124 18)[l9];$(layer 10 136 18)[l10];$(layer 11 148 18)[l11];
$(layer 12 160 18)[l12];$(layer 13 172 18)[l13];$(layer 14 184 18)[l14];$(layer 15 196 34)[l15];
[l0][l1][l2][l3][l4][l5][l6][l7][l8][l9][l10][l11][l12][l13][l14][l15]amix=inputs=16:normalize=0:duration=longest[imp];
$(mov 0xdc2c40 544 f32le 48000),highpass=f=20[celt];
[imp][celt]afir=irnorm=2,volume=2.6,highpass=f=60,lowpass=f=6000,asplit[v1][v2];
[v2]adelay=11[v2d];[v1][v2d]join=inputs=2:channel_layout=stereo,pan=stereo|c0=c0|c1=0.8*c1+0.2*c0[voice];

aevalsrc=s=48000:d=230:exprs='st(0,between(t,98,118)*eq(mod(floor((t-98)*621),1241),0)+between(t,112,130)*eq(mod(floor((t-112)*1241),1241),0)+between(t,124,142)*eq(mod(floor((t-124)*2482),1241),0));st(1,ld(0)*not(ld(2)));st(2,ld(0));ld(1)'[kt];
$(mov 0xcc09f0 1024 s16le 76800),aloop=0:512,aresample=48000[k1];
$(mov 0xcc09f0 1024 s16le 48640),aloop=0:512,aresample=48000[k2];
$(mov 0xcc09f0 1024 s16le 28160),aloop=1:512,aresample=48000[k3];
[k1][k2][k3]concat=n=3:v=0:a=1,afade=t=out:st=0.03:d=0.07:curve=exp[kir];
[kt][kir]afir=irnorm=-1,volume=0.8,pan=stereo|c0=c0|c1=c0[kick];

$(mov 0xcc09f0 1024 s16le 28160),aloop=-1:512,aresample=48000,atrim=0:230,afade=t=in:d=10,afade=t=out:st=200:d=30,volume=0.18,pan=stereo|c0=c0|c1=c0[pedal];

[voice]asplit[dry][w0];
$(mov 0x9a04 96000 u8 48000),highpass=f=250,lowpass=f=5000,afade=t=out:st=0:d=2:curve=exp,asplit[i1][i2];
[i2]adelay=9[i2d];[i1][i2d]amerge[rir];[w0][rir]afir=irnorm=2,volume=0.3[wet];
[dry][wet][kick][pedal]amix=inputs=4:normalize=0,volume=1.0,acompressor=threshold=0.3:ratio=2.5:attack=5:release=150,
 alimiter=limit=0.8:level=0,atrim=0:230,afade=t=out:st=224:d=6
" "$@"
