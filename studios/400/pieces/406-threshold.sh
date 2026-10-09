#!/bin/sh
# 406 — Threshold  (Organology VI)
#
# FORM   libavcodec's absolute-threshold-of-hearing curve (ath_base_curve, 328 x u16 at
#        0xcce600: the encoder's model of how loud a tone must be before you hear it),
#        read at one entry per second. Inverted, it is how sensitive the ear is; that is
#        the "gray level" of the piece. The curve's axis is frequency, so the music climbs
#        one octave every 82 s, and as the curve heads into the inaudible top it empties out.
# RHYTHM swscale's ordered-dither matrix ff_dither_8x8_128 (libswscale 0x11a600), the
#        table swscale uses to turn gray into dots. Each of its 8 rows is one voice of 8
#        eighth-notes (120 bpm, a bar per 2 s); a step plays when its dither threshold is
#        below the gray level. Bayer order is maximally even, so every density is a groove:
#        1, 2, then 4 hits per bar, evenly spread, and each row enters at its own gray level.
#          row5 kick  row1 bass  row7 hats  row3 stabs  row4 snare  row0/6 arps  row2 shaker
# HARMONY i VI III VII in A aeolian, a chord per 2 bars. Threshold rank sets harmonic depth:
#        the first notes a pattern gets are roots, later ones climb the stack of thirds
#        (3rd 5th 7th 9th 11th 13th), so sparse = open fifths, dense = extended chords.
# SOUND  pulsar voices on libavcodec windows (SBR QMF, CELT, MPEG enwindow); kick = g723.1
#        cosine cycles at 150/95/55 Hz; hats/snare = H.264 CABAC machine code as noise;
#        room = aac_decode_frame's code. A pure probe tone sweeps the curve's own axis,
#        0 -> 22 kHz linearly (67 Hz per second), quietly, like an audiometer.
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
S=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libswscale.10.dylib
DM=$((0x11a600))
row() { echo "subfile,,start,$((DM+8*$1+${2:-0})),end,$((DM+8*$1+${2:-0}+8)),,:$S"; }
mov() { echo "amovie='subfile,,start,$(($1)),end,$(($1+$2)),,\\:$A':f=$3:format_opts='sample_rate=$4\\:ch_layout=mono'"; }
ZOH="aresample=48000:filter_size=1:phase_shift=0"
T=328
# rows (8 thresholds each, 4 steps/s) and the hearing curve (1 entry/s), merged into one bus
R8="aloop=-1:8,$ZOH,atrim=0:$T,aformat=channel_layouts=mono"
# bus prelude: 1 gray level (0..128), 2 bar, 3 chord root degree, 4 octave, 9 step-local time
P="st(1,141*pow(min(1,max(0,(65535-(val(8)+1)*32768)/(65535-15163))),6));st(2,floor(t/2));
st(3,mod(floor(6250/pow(10,mod(floor(ld(2)/2),4))),10));st(4,min(3,floor(t/82)));st(9,mod(t*4,1)/4)"
ON="lt((val(R)+1)*128,ld(1))"
SEM="(floor((12*(DEG+5)+5)/7)-9)"
pulse() { echo "lt(mod(t*$1,1),$1/48000)"; }
# tonal voice on row R: degree = root + 2*floor(threshold/16) (stacked thirds), base 55*2^(oct+REG)
F="55*pow(2,ld(4)+REG)*pow(2,$(echo $SEM | sed 's/DEG/(ld(3)+2*floor((val(R)+1)*8)+OFS)/')/12)"
# tone ROW REG DECAY OFFSETS... : one pulse train per chord offset (0 = the note, "0 2 4" = triad on it)
tone() { r=$1; g=$2; d=$3; shift 3; on=$(echo "$ON" | sed "s/val(R)/val($r)/"); s=""
  for o in "$@"; do f=$(echo "$F" | sed "s/REG/$g/; s/val(R)/val($r)/g; s/OFS/$o/"); s="$s+$(pulse "($f)")"; done
  echo "$P;$on*exp(-ld(9)*$d)*(0$s)"; }
trig() { on=$(echo "$ON" | sed "s/val(R)/val($1)/"); echo "$P;$on*eq(mod(n,12000),0)"; }
ffmpeg -hide_banner -y \
 -f u8 -ar 4 -ac 1 -i "$(row 0)" -f u8 -ar 4 -ac 1 -i "$(row 1)" -f u8 -ar 4 -ac 1 -i "$(row 2)" \
 -f u8 -ar 4 -ac 1 -i "$(row 3)" -f u8 -ar 4 -ac 1 -i "$(row 4)" -f u8 -ar 4 -ac 1 -i "$(row 5 1)" \
 -f u8 -ar 4 -ac 1 -i "$(row 6)" -f u8 -ar 4 -ac 1 -i "$(row 7)" \
 -f u16le -ar 1 -ac 1 -i "subfile,,start,$((0xcce600)),end,$((0xcce600+656)),,:$A" \
 -filter_complex "
[0]$R8[r0];[1]$R8[r1];[2]$R8[r2];[3]$R8[r3];[4]$R8[r4];[5]$R8[r5];[6]$R8[r6];[7]$R8[r7];
[8]$ZOH,atrim=0:$T,aformat=channel_layouts=mono[ath];
[r0][r1][r2][r3][r4][r5][r6][r7][ath]amerge=inputs=9,
aeval=exprs='$(trig 5)|$(trig 4)|$(trig 7)|$(trig 2)|$(tone 1 0 6 0)|$(tone 3 1 9 0 2 4)|$(tone 0 2 14 0)|$(tone 6 2 18 0)':channel_layout=7.1,
channelsplit=channel_layout=7.1[kt][st][ht][pt][bp][sp][a1][a2];

$(mov 0xcc09f0 1024 s16le 76800),aloop=0:512,aresample=48000[k1];
$(mov 0xcc09f0 1024 s16le 48640),aloop=0:512,aresample=48000[k2];
$(mov 0xcc09f0 1024 s16le 28160),aloop=1:512,aresample=48000[k3];
[k1][k2][k3]concat=n=3:v=0:a=1,afade=t=out:st=0.03:d=0.08:curve=exp[kir];
[kt][kir]afir=irnorm=-1,volume=0.85,asplit[kick][kside];

$(mov 0x2f42c4 2400 u8 48000),highpass=f=7000,afade=t=out:st=0:d=0.045:curve=exp[hir];
[ht][hir]afir=irnorm=2,volume=2.5[hat];
$(mov 0x2f9000 9600 u8 48000),bandpass=f=1800:w=1.2,afade=t=out:st=0:d=0.18:curve=exp[sir];
[st][sir]afir=irnorm=2,volume=3[snare];
$(mov 0x2fb000 4800 u8 48000),highpass=f=3500,afade=t=out:st=0:d=0.09:curve=exp[pir];
[pt][pir]afir=irnorm=2,volume=1.2[shk];

$(mov 0xcc09f0 1024 s16le 48000),aloop=0:512,aresample=48000[bir];
[bp][bir]afir=irnorm=2,volume=1.0,lowpass=f=900[bass0];
[bass0][kside]sidechaincompress=threshold=0.04:ratio=5:attack=2:release=140[bass];
$(mov 0xc0a640 2560 f32le 48000),highpass=f=30[qir];
[sp][qir]afir=irnorm=2,volume=1.3,lowpass=f=4500[stab];
$(mov 0xdc2c40 544 f32le 48000),highpass=f=30[cir];
[a1][cir]afir=irnorm=2,volume=0.9,lowpass=f=7000[arp1];
$(mov 0xd93e78 1056 s32le 96000),highpass=f=30[eir];
[a2][eir]afir=irnorm=2,volume=0.5,lowpass=f=9000[arp2];

[kick]pan=stereo|c0=c0|c1=c0[K];[bass]pan=stereo|c0=c0|c1=c0[B];
[snare]pan=stereo|c0=0.9*c0|c1=c0[SN];[hat]pan=stereo|c0=0.55*c0|c1=c0[H];[shk]pan=stereo|c0=c0|c1=0.5*c0[SH];
[stab]asplit[s1][s2];[s2]adelay=13[s2d];[s1][s2d]join=inputs=2:channel_layout=stereo[ST];
[arp1]pan=stereo|c0=c0|c1=0.35*c0[A1];[arp2]pan=stereo|c0=0.35*c0|c1=c0[A2];
[ST][A1][A2][SN]amix=inputs=4:normalize=0,asplit[tdry][tw];
aevalsrc=s=48000:d=$T:exprs='st(0,mod(ld(0)+t*22050/$T/48000,1));0.02*sin(2*PI*ld(0))*min(1,t/4)*pow(min(1,(65535-(15163+0*t))/50372),1)':channel_layout=mono,
 volume='0.6*pow(max(0,1-t/$T),0.5)':eval=frame,pan=stereo|c0=c0|c1=c0[probe];
$(mov 0x9a04 72000 u8 48000),highpass=f=250,lowpass=f=5000,afade=t=out:st=0:d=1.5:curve=exp,asplit[i1][i2];
[i2]adelay=7[i2d];[i1][i2d]amerge[rir];[tw][rir]afir=irnorm=2,volume=0.3[wet];
[K][B][H][SH][tdry][wet][probe]amix=inputs=7:normalize=0,volume=1.2,acompressor=threshold=0.3:ratio=2.5:attack=5:release=120,
 alimiter=limit=0.8:level=0,atrim=0:$T,afade=t=out:st=$(($T-8)):d=8
" "$@"
