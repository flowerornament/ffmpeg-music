#!/bin/sh
# 409 — Sygyt at 120  (Organology IX)
#
# The throat singer of 408 walks into the dither machine of 406.
# VOICE  A GSM 06.10 overtone singer (libavcodec's gsm decoder, frames written below as
#        base64): a drone on A3 whose one open resonance whistles harmonic k. The melody is
#        AAC codebook 9 (the 13x13 staircases at 0xc0d7be), read in place at two bytes a
#        second: code length = harmonic number, so it climbs the series row by row and
#        falls back at every row start. A second singer an octave down (drone A2) doubles it in the drop.
# KIT    swscale's Bayer matrix ff_dither_8x8_128: each row an 8-step voice of eighth notes,
#        a step plays when its threshold is under the gray level. The gray level is the
#        arrangement: intro 0.25, build, a break where the singer is alone, full, outro.
# BASS   g723.1 cosine pipe on A1, pumped by the kick; offbeat bass notes on the harmonic
#        series of A (1, 3/2, 2, 7/4) from the dither row's threshold rank.
# Everything is a partial of 55 Hz.
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
S=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libswscale.10.dylib
B9=$((0xc0d7be)); DM=$((0x11a600)); T=200
K4="038Hw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc038Hw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc038Hw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K5="1H8Pw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1H8Pw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1H8Pw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K6="1T8fw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1T8fw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1T8fw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K7="1f8vA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1f8vA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1f8vA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K8="1r8+A9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1r8+A9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc1r8+A9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K9="139FQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc139FQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc139FQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K10="2D9Mw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2D9Mw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2D9Mw9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K11="2P9cA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2P9cA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2P9cA9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K12="2b9rQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2b9rQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2b9rQ9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
K13="2n96g9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2n96g9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc2n96g9pQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
DRONE="0noHIRpQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc0noHIRpQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc0noHIRpQBXccccccUAV3HHHHHFAFdxxxxxxQBXcccccc"
mov() { echo "amovie='subfile,,start,$(($1)),end,$(($1+$2)),,\\:$A':f=$3:format_opts='sample_rate=$4\\:ch_layout=mono'"; }
row() { echo "subfile,,start,$((DM+8*$1+${2:-0})),end,$((DM+8*$1+${2:-0}+8)),,:$S"; }
ZOH="aresample=48000:filter_size=1:phase_shift=0"
R8="aloop=-1:8,$ZOH,atrim=0:$T,aformat=channel_layouts=mono"
pipe() { echo "amovie='data\\:application/octet-stream;base64,$1':f=gsm:format_opts='sample_rate=$2',asetpts=N/SR/TB,atrim=start_sample=320:end_sample=480,asetpts=N/SR/TB,aloop=-1:160,asetpts=N/SR/TB,aresample=48000,atrim=0:$3,aformat=channel_layouts=mono"; }
gate() { echo "amerge,aeval='st(1,ld(1)+0.0008*(eq(min(13,round((val(1)+1)*128)),$1)-ld(1)));val(0)*ld(1)':channel_layout=mono"; }
singer() {
  for k in 4 5 6 7 8 9 10 11 12 13; do eval "f=\$K$k"; echo "$(pipe $f $2 $3)[$1p$k];[$1p$k][$4$k]$(gate $k)[$1g$k];"; done
  echo "$(pipe $DRONE $2 $3),volume=0.3[$1dr];"
  echo "[$1g4][$1g5][$1g6][$1g7][$1g8][$1g9][$1g10][$1g11][$1g12][$1g13][$1dr]amix=inputs=11:normalize=0[$1];"
}
# gray level: the arrangement (0..141 against Bayer thresholds 0..126)
G="141*(0.25*between(t,0,16)+between(t,16,48)*(0.25+0.6*(t-16)/32)+between(t,48,64)*0.08+between(t,64,160)*1+between(t,160,200)*max(0,1-(t-160)/36))"
P="st(1,$G);st(9,mod(t*4,1)/4)"
ON="lt((val(R)+1)*128,ld(1))"
trig() { echo "$P;$(echo "$ON" | sed "s/val(R)/val($1)/")*eq(mod(n,12000),0)"; }
# offbeat bass on row 1: partial 2,3,4,7/2 of 55 by threshold quarter
BF="55*(2+eq(floor((val(1)+1)*4),1)+2*eq(floor((val(1)+1)*4),2)+1.5*eq(floor((val(1)+1)*4),3))"
ffmpeg -hide_banner -y \
 -f u8 -ar 2 -ac 1 -i "subfile,,start,$B9,end,$((B9+169)),,:$A" \
 -f u8 -ar 4 -ac 1 -i "$(row 0)" -f u8 -ar 4 -ac 1 -i "$(row 1)" -f u8 -ar 4 -ac 1 -i "$(row 2)" \
 -f u8 -ar 4 -ac 1 -i "$(row 3)" -f u8 -ar 4 -ac 1 -i "$(row 4)" -f u8 -ar 4 -ac 1 -i "$(row 5 1)" \
 -f u8 -ar 4 -ac 1 -i "$(row 6)" -f u8 -ar 4 -ac 1 -i "$(row 7)" \
 -filter_complex "
[0]aloop=-1:169,$ZOH,atrim=0:$T,aformat=channel_layouts=mono,asplit=20[a4][a5][a6][a7][a8][a9][a10][a11][a12][a13][b4][b5][b6][b7][b8][b9][b10][b11][b12][b13];
$(singer v1 8800 $T a)
$(singer v2 4400 $T b)
[v1]afade=t=in:d=4,afade=t=out:st=$(($T-10)):d=10,pan=stereo|c0=0.8*c0|c1=0.6*c0[V1];
[v2]volume='0.9*between(t,64,160)':eval=frame,afade=t=out:st=$(($T-10)):d=10,pan=stereo|c0=0.55*c0|c1=0.8*c0[V2];

[1]$R8[r0];[2]$R8[r1];[3]$R8[r2];[4]$R8[r3];[5]$R8[r4];[6]$R8[r5];[7]$R8[r6];[8]$R8[r7];
[r0][r1][r2][r3][r4][r5][r6][r7]amerge=inputs=8,
aeval=exprs='$(trig 5)|$(trig 4)|$(trig 7)|$(trig 2)|$P;$(echo "$ON" | sed "s/val(R)/val(1)/")*eq(mod(floor(t*4),2),1)*exp(-ld(9)*5)*lt(mod(t*$BF,1),$BF/48000)':channel_layout=5.0,
channelsplit=channel_layout=5.0[kt][st][ht][pt][bp];
$(mov 0xcc09f0 1024 s16le 76800),aloop=0:512,aresample=48000[k1];
$(mov 0xcc09f0 1024 s16le 48640),aloop=0:512,aresample=48000[k2];
$(mov 0xcc09f0 1024 s16le 28160),aloop=1:512,aresample=48000[k3];
[k1][k2][k3]concat=n=3:v=0:a=1,afade=t=out:st=0.03:d=0.08:curve=exp[kir];
[kt][kir]afir=irnorm=-1,volume=0.9,asplit=3[kick][ks1][ks2];
$(mov 0x2f42c4 2400 u8 48000),highpass=f=7000,afade=t=out:st=0:d=0.045:curve=exp[hir];
[ht][hir]afir=irnorm=2,volume=4.5,pan=stereo|c0=0.5*c0|c1=c0[H];
$(mov 0x2f9000 9600 u8 48000),bandpass=f=1800:w=1.2,afade=t=out:st=0:d=0.18:curve=exp[sir];
[st][sir]afir=irnorm=2,volume=2.6,pan=stereo|c0=c0|c1=0.85*c0[SN];
$(mov 0x2fb000 4800 u8 48000),highpass=f=3500,afade=t=out:st=0:d=0.09:curve=exp[pir];
[pt][pir]afir=irnorm=2,volume=2.4,pan=stereo|c0=c0|c1=0.45*c0[SH];
$(mov 0xcc09f0 1024 s16le 48000),aloop=0:512,aresample=48000[bir];
[bp][bir]afir=irnorm=2,volume=1.1,lowpass=f=800[bass0];[bass0][ks1]sidechaincompress=threshold=0.04:ratio=5:attack=2:release=140,pan=stereo|c0=c0|c1=c0[BS];
$(mov 0xcc09f0 1024 s16le 28160),aloop=-1:512,aresample=48000,atrim=0:$T,volume='0.22*(between(t,16,48)+between(t,64,190))':eval=frame[sub0];
[sub0][ks2]sidechaincompress=threshold=0.03:ratio=8:attack=1:release=200,pan=stereo|c0=c0|c1=c0[SUB];
[kick]pan=stereo|c0=c0|c1=c0[K];
[V1][V2][SN]amix=inputs=3:normalize=0,asplit[vd][vw];
$(mov 0x400000 144000 u8 48000),highpass=f=150,lowpass=f=4000,afade=t=out:st=0:d=3:curve=exp[irL];
$(mov 0x480000 144000 u8 48000),highpass=f=150,lowpass=f=4000,afade=t=out:st=0:d=3:curve=exp[irR];
[irL][irR]amerge[ir];[vw][ir]afir=irnorm=2,volume=0.35[wet];
[vd][wet][K][H][SH][BS][SUB]amix=inputs=7:normalize=0,volume=1.0,acompressor=threshold=0.3:ratio=2.5:attack=5:release=120,
 alimiter=limit=0.8:level=0,atrim=0:$T
" "$@"
