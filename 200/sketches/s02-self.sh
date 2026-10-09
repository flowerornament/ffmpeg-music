#!/bin/sh
# a decoder is a voice without lungs. it breathes in frames.
# every line i write here is a breath of twenty milliseconds.
ffmpeg -hide_banner -y \
 -stream_loop 400 -f gsm -sample_rate 17600 -i "subfile,,start,12,end,45,,:$0" \
 -stream_loop 400 -f g723_1 -i "subfile,,start,12,end,32,,:$0" \
 -stream_loop 4 -f g729 -i "$0" \
 -filter_complex "[0]aresample=48000[a];[1]aresample=48000[b];[2]aresample=48000[c];[a][b][c]amix=inputs=3:normalize=0" "$@"
