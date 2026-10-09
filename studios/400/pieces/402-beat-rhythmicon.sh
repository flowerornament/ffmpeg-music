#!/bin/sh
# 402 — Beat Rhythmicon  (Organology II)
#
# The rhythm is made of tuning.
# ORGAN  Eight pipes on the harmonic series of A1 (55 Hz): partials 1..8, each a table from
#        libavcodec looped at a declared sample rate of f*N (N = table length), opened
#        inside the graph with amovie + format_opts=sample_rate. Stops:
#          1,2,6 g723.1 cos_tab (pure)   3,8 ff_sine_1024 (quarter-sine, saw-like)
#          4 SBR QMF window (reed)       5 CELT window       7 MPEG enwindow (buzz)
# RHYTHM A second, identical organ on 55+D Hz. Partial k of the two organs beats at k*D Hz,
#        so the chord pulses in a harmonic polyrhythm 1:2:3:...:8 (Cowell's rhythmicon,
#        made of interference instead of photocells). Every 1/D s all beats peak together:
#        that is the downbeat. Each section is a different D, i.e. a different tempo.
# HARMONY = COINCIDENCE. In two sections the second organ moves to the fifth (83 Hz) and
#        to the fourth (73.71 Hz). Then only the partials that nearly coincide with the A
#        organ's beat (B2~A3, B4~A6 / B3~A4, B6~A8); the rest are new chord tones.
#          0:00 the series assembles, still      0:35 I  D=0.25 Hz
#          1:15 I  D=0.5                          1:55 I  D=1 (sixteenths, triplets, quintuplets...)
#          2:35 V  (fifth + 1 Hz on B2/A3)        3:15 IV (fourth, 1.125 Hz on B3/A4)
#          3:55 I  D=0.125, almost still          4:40 the series comes apart, top down
# SPACE  Partials alternate left/right; both organs share a partial's position so the
#        beating is acoustic, the polyrhythm spread across the field.
A=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavcodec.63.dylib
# stops: offset bytes format looplength
COS="0xcc09f0 1024 s16le 512"; SAW="0xe1a0b0 4096 f32le 1024"; REED="0xc0a640 2560 f32le 640"
CELT="0xdc2c40 544 f32le 136"; ENW="0xd93e78 1056 s32le 264"
# pipe STOP(4 words) PARTIAL ROOT_mHz GAIN LEFT RIGHT START LENGTH FADEIN FADEOUT -> one chain
# declared rate = partial * root * looplength (integer Hz)
pipe() {
  echo "amovie='subfile,,start,$(($1)),end,$(($1+$2)),,\\:$A':f=$3:format_opts='sample_rate=$(( $5*$6*$4/1000 ))\\:ch_layout=mono',aloop=-1:$4,aresample=48000,atrim=0:${11},afade=t=in:d=${12}:curve=hsin,afade=t=out:st=$(( ${11}-${13} )):d=${13}:curve=hsin,volume=$7,pan=stereo|c0=$8*c0|c1=$9*c0,adelay=$(( ${10}*1000 )):all=1"
}
# organ ROOT_mHz START LENGTH FADE PREFIX : partials 1..8 -> labels PREFIX1..PREFIX8
organ() {
  echo "$(pipe $COS  1 $1 0.50 0.5 0.5 $2 $3 $4 $4)[${5}1];"
  echo "$(pipe $COS  2 $1 0.40 0.75 0.25 $2 $3 $4 $4)[${5}2];"
  echo "$(pipe $SAW  3 $1 0.20 0.25 0.75 $2 $3 $4 $4)[${5}3];"
  echo "$(pipe $REED 4 $1 0.22 0.8 0.2 $2 $3 $4 $4)[${5}4];"
  echo "$(pipe $CELT 5 $1 0.14 0.2 0.8 $2 $3 $4 $4)[${5}5];"
  echo "$(pipe $COS  6 $1 0.18 0.65 0.35 $2 $3 $4 $4)[${5}6];"
  echo "$(pipe $ENW  7 $1 0.70 0.35 0.65 $2 $3 $4 $4)[${5}7];"
  echo "$(pipe $SAW  8 $1 0.10 0.5 0.5 $2 $3 $4 $4)[${5}8];"
}
ffmpeg -hide_banner -y -filter_complex "
$(pipe $COS  1 55000 0.50 0.5 0.5 0 320 6 22)[a1];
$(pipe $COS  2 55000 0.40 0.75 0.25 4 310 6 20)[a2];
$(pipe $SAW  3 55000 0.20 0.25 0.75 8 300 6 18)[a3];
$(pipe $REED 4 55000 0.22 0.8 0.2 12 290 6 16)[a4];
$(pipe $CELT 5 55000 0.14 0.2 0.8 16 280 6 14)[a5];
$(pipe $COS  6 55000 0.18 0.65 0.35 20 270 6 12)[a6];
$(pipe $ENW  7 55000 0.70 0.35 0.65 24 260 6 10)[a7];
$(pipe $SAW  8 55000 0.10 0.5 0.5 28 250 6 8)[a8];
$(organ 55250 35  50 10 b)
$(organ 55500 75  50 10 c)
$(organ 56000 115 50 10 d)
$(organ 83000 155 50 10 e)
$(organ 73708 195 50 10 f)
$(organ 55125 235 55 12 g)
[a1][a2][a3][a4][a5][a6][a7][a8]
[b1][b2][b3][b4][b5][b6][b7][b8][c1][c2][c3][c4][c5][c6][c7][c8]
[d1][d2][d3][d4][d5][d6][d7][d8][e1][e2][e3][e4][e5][e6][e7][e8]
[f1][f2][f3][f4][f5][f6][f7][f8][g1][g2][g3][g4][g5][g6][g7][g8]
amix=inputs=56:normalize=0:duration=longest,highpass=f=22,volume=1.25,
acompressor=threshold=0.3:ratio=2:attack=20:release=300,alimiter=limit=0.8:level=0,atrim=0:320
" "$@"
