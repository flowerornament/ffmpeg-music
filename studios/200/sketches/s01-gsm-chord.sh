#!/bin/sh
# sketch: four 33-char words (one GSM frame each) looped, sample rates as a JI chord (f = sr/160)
ffmpeg -hide_banner -y \
 -stream_loop -1 -f gsm -sample_rate 17600 -i "data:,the quick brown fox jumps over th" \
 -stream_loop -1 -f gsm -sample_rate 21120 -i "data:,a decoder is a voice without lung" \
 -stream_loop -1 -f gsm -sample_rate 26400 -i "data:,every frame a breath of twenty ms" \
 -stream_loop -1 -f gsm -sample_rate 31680 -i "data:,monograph monograph monograph mon" \
 -filter_complex "[0][1][2][3]amix=inputs=4:normalize=0,aresample=48000,atrim=0:20,afade=t=out:st=17:d=3,alimiter" "$@"
