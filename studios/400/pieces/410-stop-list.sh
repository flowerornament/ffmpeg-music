#!/bin/sh
# 410 — Stop List  (Organology, opening)
#
# The organ introduces its registers before anything is played on it. Over a pedal on A1
# (g723.1's cosine table), each stop enters on one partial of 55 Hz and holds:
#   0:00 pedal 16'      g723.1 cos_tab           A1  55 Hz   (partial 1)
#   0:06 flute 8'       g723.1 cos_tab           A2 110      (2)
#   0:12 principal      ff_sine_1024             E3 165      (3)
#   0:18 reed           SBR QMF window           A3 220      (4)
#   0:24 gamba          CELT window              C#4 275     (5)
#   0:30 nazard         g723.1 cos_tab           E4 330      (6)
#   0:36 trompette      MPEG enwindow            G4 385      (7, the natural seventh)
#   0:42 cymbale        ff_sine_1024             A4 440      (8)
# Each pipe is a table looped at a declared sample rate of f*N. From 0:48 the stops close
# again, top down, and the pedal is left alone. This is the whole stop list of the record.
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
COS="0xcc09f0 1024 s16le 512"; SAW="0xe1a0b0 4096 f32le 1024"; REED="0xc0a640 2560 f32le 640"
CELT="0xdc2c40 544 f32le 136"; ENW="0xd93e78 1056 s32le 264"
# pipe STOP(4) PARTIAL GAIN LEFT RIGHT ENTER_S CLOSE_S
pipe() {
  echo "amovie='subfile,,start,$(($1)),end,$(($1+$2)),,\\:$A':f=$3:format_opts='sample_rate=$(( $5*55*$4 ))\\:ch_layout=mono',aloop=-1:$4,aresample=48000,atrim=0:$(( ${10}-$9+4 )),afade=t=in:d=2.5:curve=hsin,afade=t=out:st=$(( ${10}-$9 )):d=4:curve=hsin,volume=$6,pan=stereo|c0=$7*c0|c1=$8*c0,adelay=$(( $9*1000 )):all=1"
}
ffmpeg -hide_banner -y -filter_complex "
$(pipe $COS  1 0.50 0.5  0.5  0  66)[p1];
$(pipe $COS  2 0.40 0.7  0.3  6  64)[p2];
$(pipe $SAW  3 0.18 0.3  0.7  12 62)[p3];
$(pipe $REED 4 0.20 0.8  0.2  18 60)[p4];
$(pipe $CELT 5 0.12 0.2  0.8  24 58)[p5];
$(pipe $COS  6 0.16 0.65 0.35 30 56)[p6];
$(pipe $ENW  7 0.60 0.35 0.65 36 54)[p7];
$(pipe $SAW  8 0.08 0.5  0.5  42 52)[p8];
[p1][p2][p3][p4][p5][p6][p7][p8]amix=inputs=8:normalize=0:duration=longest,highpass=f=22,asplit[dry][w0];
amovie='subfile,,start,$((0x9a04)),end,$((0x9a04+144000)),,\\:$A':f=u8:format_opts='sample_rate=48000\\:ch_layout=mono',highpass=f=200,lowpass=f=4000,afade=t=out:st=0:d=3:curve=exp,asplit[i1][i2];
[i2]adelay=11[i2d];[i1][i2d]amerge[ir];[w0][ir]afir=irnorm=2,volume=0.3[wet];
[dry][wet]amix=inputs=2:normalize=0,volume=1.3,alimiter=limit=0.8:level=0,atrim=0:72
" "$@"
