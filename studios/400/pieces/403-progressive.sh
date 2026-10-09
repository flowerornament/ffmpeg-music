#!/bin/sh
# 403 — Progressive  (Organology III)
#
# A 64-step loop is one 8x8 DCT block. Step s = (u,v): u = row (vertical frequency),
# v = column (horizontal frequency), 8 steps/s (sixteenths at 120 bpm), 8 s per block.
# ARRIVAL  Steps arrive in the order HEVC scans coefficients (diag_scan8x8_inv, libavcodec
#        0xccf05c: each position's rank). Block n plays every step whose rank < 4(n+1):
#        progressive decoding, low frequencies first, so the groove grows from the bass up.
#        After 16 blocks (full) and 4 held, it is compressed: steps leave in reverse rank,
#        highest frequencies first, as if the quantizer were turned up, until only DC is left.
# KIT    by spatial frequency u+v, like JPEG's own priorities:
#          kick  = steps on the 4-grid in the low half (u+v<=7)
#          tones = every step with 1<=u+v<=10: pitches = partials (u+1),(v+1) of the root
#          hats  = u+v>=7, noise from the machine code of the H.264 CABAC decoder
#        velocity = 16/q from the JPEG standard luminance quantization table (0xd04884),
#        so the hits the codec protects most are loudest. Column v = stereo position.
# HARMONY  root per block cycles A F D E (just ratios 1, 4/5, 2/3, 3/4); sub = cosine pipes.
# SOUND  tone pulsaret = SBR QMF window; kick = g723.1 cosine, one cycle each at 150, 95,
#        then two at 55 Hz (a pitch drop made of whole cycles); room = aac_decode_frame code.
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
C=$((0xcc09f0))
tab() { echo "subfile,,start,$(($1)),end,$(($1+$2)),,:$A"; }
mov() { echo "amovie='subfile,,start,$(($1)),end,$(($1+$2)),,\\:$A':f=$3:format_opts='sample_rate=$4\\:ch_layout=mono'"; }
ZOH="aresample=48000:filter_size=1:phase_shift=0"
# shared prelude: 1 step s, 2 block n, 3 rank r, 4 quant q, 5 u, 6 v, 7 active, 8 root ratio
P="st(1,mod(floor(t*8),64));st(2,floor(t/8));st(3,round((val(0)+1)*128));st(4,round((val(1)+1)*128));
st(5,floor(ld(1)/8));st(6,mod(ld(1),8));st(7,lt(ld(3),min(4*ld(2)+4,140-4*ld(2))));
st(8,1-0.2*eq(mod(ld(2),4),1)-0.3333333*eq(mod(ld(2),4),2)-0.25*eq(mod(ld(2),4),3));st(9,mod(t*8,1)/8)"
TONE="ld(7)*between(ld(5)+ld(6),1,10)*sqrt(16/ld(4))*exp(-ld(9)*14)*(lt(mod(t*110*ld(8)*(ld(5)+1),1),110*ld(8)*(ld(5)+1)/48000)+lt(mod(t*110*ld(8)*(ld(6)+1),1),110*ld(8)*(ld(6)+1)/48000))"
ONSET="eq(mod(n,6000),0)"
# sub pipe on root ratio k (g723.1 cos at 55*ratio Hz), gated per block
sub() { echo "$(mov $C 1024 s16le $2),aloop=-1:512,aresample=48000,atrim=0:288,aeval='st(2,floor(t/8));st(1,ld(1)+0.0004*(eq(mod(ld(2),4),$1)*lt(ld(2),35)-ld(1)));val(0)*ld(1)'"; }
ffmpeg -hide_banner -y \
 -f u8 -ar 8 -ac 1 -i "$(tab 0xccf05c 64)" \
 -f u8 -ar 8 -ac 1 -i "$(tab 0xd04884 64)" \
 -filter_complex "
[0]aloop=-1:64,$ZOH,atrim=0:288,aformat=channel_layouts=mono[rk];[1]aloop=-1:64,$ZOH,atrim=0:288,aformat=channel_layouts=mono[qt];[rk][qt]amerge=inputs=2,
aeval=exprs='$P;$TONE*(1-ld(6)/7)|$P;$TONE*ld(6)/7|$P;ld(7)*$ONSET*eq(mod(ld(1),4),0)*lte(ld(5)+ld(6),7)|$P;ld(7)*$ONSET*gte(ld(5)+ld(6),7)*sqrt(16/ld(4))|$P;ld(8)':channel_layout=5.0,
channelsplit=channel_layout=5.0[tl][tr][kt][ht][rt];
[rt]anullsink;
$(mov 0xc0a640 2560 f32le 48000),highpass=f=20,asplit[q1][q2];
[tl][q1]afir=irnorm=2,volume=6[tL];[tr][q2]afir=irnorm=2,volume=6[tR];
[tL][tR]join=inputs=2:channel_layout=stereo,pan=stereo|c0=c0+0.25*c1|c1=c1+0.25*c0,lowpass=f=5000,highpass=f=90[tones];

$(mov $C 1024 s16le 76800),aloop=0:512,aresample=48000[k1];
$(mov $C 1024 s16le 48640),aloop=0:512,aresample=48000[k2];
$(mov $C 1024 s16le 28160),aloop=1:512,aresample=48000[k3];
[k1][k2][k3]concat=n=3:v=0:a=1,afade=t=out:st=0.03:d=0.06:curve=exp[kir];
[kt][kir]afir=irnorm=-1,volume=0.9,asplit[kick][kside];

$(mov 0x2f42c4 2400 u8 48000),highpass=f=6000,afade=t=out:st=0:d=0.05:curve=exp[hir];
[ht][hir]afir=irnorm=2,volume=5,pan=stereo|c0=0.7*c0|c1=c0,adecorrelate=stages=3[hats];

$(sub 0 28160)[s0];$(sub 1 22528)[s1];$(sub 2 18773)[s2];$(sub 3 21120)[s3];
[s0][s1][s2][s3]amix=inputs=4:normalize=0,volume=0.3[sub0];
[sub0][kside]sidechaincompress=threshold=0.05:ratio=6:attack=2:release=180[sub];

[tones][hats]amix=inputs=2:normalize=0,asplit[dry][w0];
$(mov 0x9a04 72000 u8 48000),highpass=f=250,lowpass=f=5000,afade=t=out:st=0:d=1.5:curve=exp,asplit[i1][i2];
[i2]adelay=7[i2d];[i1][i2d]amerge[rir];
[w0][rir]afir=irnorm=2,volume=0.25[wet];
[kick]pan=stereo|c0=c0|c1=c0[k];[sub]pan=stereo|c0=c0|c1=c0[s];
[dry][wet][k][s]amix=inputs=4:normalize=0,volume=1.3,acompressor=threshold=0.3:ratio=2.5:attack=5:release=120,
 alimiter=limit=0.8:level=0,atrim=0:288,afade=t=out:st=282:d=6
" "$@"
