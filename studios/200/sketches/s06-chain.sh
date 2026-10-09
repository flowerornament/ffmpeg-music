#!/bin/sh
# sketch: 6 generations of one codec inside one command (loopback decoders). usage: s06-chain.sh CODEC RATE out.wav
C=$1; R=$2; shift 2
ffmpeg -hide_banner -y -stream_loop 30 -f gsm -sample_rate 8000 -i "subfile,,start,10,end,538,,:studios/200/pieces/201-prolation.sh" \
 -filter_complex "[0]asetpts=N/SR/TB,aresample=$R,aformat=channel_layouts=mono,atrim=0:8,asplit[g0][m0]" -map "[g0]" -c:a $C -f null - -dec 0:0 \
 -filter_complex "[dec:0]aresample=$R,asplit[g1][m1]" -map "[g1]" -c:a $C -f null - -dec 1:0 \
 -filter_complex "[dec:1]aresample=$R,asplit[g2][m2]" -map "[g2]" -c:a $C -f null - -dec 2:0 \
 -filter_complex "[dec:2]aresample=$R,asplit[g3][m3]" -map "[g3]" -c:a $C -f null - -dec 3:0 \
 -filter_complex "[dec:3]aresample=$R,asplit[g4][m4]" -map "[g4]" -c:a $C -f null - -dec 4:0 \
 -filter_complex "[dec:4]aresample=$R,asplit[g5][m5]" -map "[g5]" -c:a $C -f null - -dec 5:0 \
 -filter_complex "[m0][m1][m2][m3][m4][m5][dec:5]amerge=inputs=7,aresample=16000[out]" -map "[out]" "$@"
