# writes ../pieces/208-untransmitted.sh (o-runs counted here; the score is literal)
rates=[1572,1179,917,786,655,524,393,262]
ends =[22,30,38,46,54,62,68,74]
gains=[0.3,0.35,0.4,0.55,0.6,0.75,0.8,1.0]
hdr='''#!/bin/sh
# 208 — UNTRANSMITTED (coda)
#
# The record ends on the frame it is named after. In G.723.1 a one-byte frame whose
# first bits say "untransmitted" means: nothing was sent this time. In ASCII the
# letter o is such a frame. After a comfort-noise word it holds the noise; after
# speech it conceals, fading; before anything at all it is silence the decoder
# computes, 30 ms at a time.
#
# Eight voices say the first word of 202, "bool", at the overtone series of D
# (asetrate 262 x k/2), and each is given a different number of o's, so they leave
# one at a time from the top down, a farewell. When the last one has gone, a ninth
# decoder that has been receiving nothing for 74 seconds (617 o's) gets one speech
# frame, "the line is still open..", slowed to a low thud, and then 70 more o's:
# eight seconds of silence that is not the end of the file but a decoder still
# listening, told each 30 ms that nothing was sent.
ffmpeg -hide_banner -y \\
'''
s=hdr
for sr,e in zip(rates,ends):
    n=round(e*sr/240)-1
    s+=f' -f g723_1 -i "data:,bool{"o"*n}" \\\n'
s+=' -f g723_1 -i "data:,'+'o'*617+'the line is still open..'+'o'*70+'" \\\n'
fc=' -filter_complex "\n'
for i,(sr,e,g) in enumerate(zip(rates,ends,gains)):
    sh='anull' if sr==262 else 'afreqshift=shift=0.28'
    fc+=f" [{i}]asetrate={sr},aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,volume={g*11:.2f},afade=t=out:st={e-6}:d=6,asplit[a{i}][b{i}0];[b{i}0]{sh}[b{i}];\n"
fc+=" [8]asetrate=2000,aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,volume=6,asplit[a8][b8];\n"
fc+=' '+''.join(f'[a{i}]' for i in range(9))+'amix=inputs=9:normalize=0:duration=longest[L];\n'
fc+=' '+''.join(f'[b{i}]' for i in range(9))+'amix=inputs=9:normalize=0:duration=longest[R];\n'
fc+=' [L][R]amerge=inputs=2,alimiter=level=0:limit=0.8:attack=20:release=200[out]" -map "[out]" "$@"\n'
open('../pieces/208-untransmitted.sh','w').write(s+fc)
