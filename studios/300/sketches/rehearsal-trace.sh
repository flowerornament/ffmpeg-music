#!/bin/bash
# rehearsal-trace.sh — print the chord roots that 306's learner chooses, 20 per line.
# Extracts the S/LEARN variables from the piece and runs only the learner (no drawing).
cd "$(dirname "$0")"
eval "$(sed -n '/^S=/,/^st(1,ld(9))"/p' ../pieces/306-rehearsal.sh)"
ffmpeg -hide_banner -loglevel error -y -filter_complex "aevalsrc=s=48000:d=186:exprs='if(eq(mod(n,$S),0)*gt(n,0),$LEARN,0);ld(1)/8'" -f f32le -c:a pcm_f32le - |
python3 -c "
import sys,struct
d=sys.stdin.buffer.read(); x=struct.unpack('<%df'%(len(d)//4),d)
R='I ii iii IV V vi vii'.split(); s=[R[round(x[k*72000+100]*8)] for k in range(len(x)//72000)]
for i in range(0,len(s),20): print(i, ' '.join(s[i:i+20]))"
