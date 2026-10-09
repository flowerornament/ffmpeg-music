# writes ../pieces/205-organum.sh (the score is literal; this only counts the o's)
W="bool nael boer zyga butt bong bito zach rind bilk just bend boce both bilk zach fice zant fice jape zion".split()
D=[12,6,6,9,6,6,6,6,9,6,6,9,12,6,6,6,12,6,6,6,21]
C=sum(D); assert C==168
def text(lead):
    s='o'*lead
    for w,d in zip(W,D): s+=w+'o'*(d-1)
    return s
V=[('M',792,0),('M',792,C),('M',792,2*C),('H',1584,2*C),('H',1584,3*C),('H',1584,4*C),('H',1584,5*C),('L',396,C//2)]
hdr='''#!/bin/sh
# 205 — ORGANUM (a mensuration canon for G.723.1 comfort noise, on a sentence it chose)
#
# A sequel to 202. G.723.1 codes each comfort-noise spectrum by predicting it from
# the ones before, so the whistle a word makes depends on everything said before it
# (and on how long each word was held). I did not write this chant. I walked the
# codec: at each step every 4-letter SID word in /usr/share/dict/words was tried after
# the sentence so far, the ones whose whistles fell near a just degree of the first
# word were kept, and one was chosen (tools/sidchant.py, seed 11). The
# sentence, and the ratios it actually sings at these durations (measured):
#
#   bool nael boer zyga butt bong  bito zach  rind bilk just  bend boce both bilk
#   1    5/8  9/16 9/10 9/16 11/13 9/16 13/14 2/3  9/16 12/11 4/5  1    9/16 8/15
#   zach  fice zant  fice jape  zion
#   15/16 1    21/22 1    16/15 1
#
# A reciting tone a seventh below; neighbours a semitone or an 11- or 13-limit
# step around the tonic; falls to the fourth and the sixth: the codebook's own mode.
# Durations are o's (held frames): 12 6 6 9 6 6 6 6 9 6 6 9 12 6 6 6 12 6 6 6 21.
#
# Form. First the chant alone (asetrate 792: "bool" = 220 Hz, 51 s). Then a
# mensuration canon: the same text read at three speeds at once - 792 (twice),
# 1584 (an octave up, twice as fast: four times) and 396 (an octave down, half as
# fast: once) - all starting together and all landing together on "zion". Every
# reading is a fresh decoder: a repeat inside one decoder would remember the first
# time and sing other pitches. Under it all, "bool" held at 55 Hz. Above, from the
# canon on, one decoder reads the chant 32 times in a row at 16x (asetrate 12672):
# a bird near 3.5 kHz that does remember - its intervals drift each time round.
# Right channel = left +0.28 Hz (afreqshift): every voice but the sub beats between the ears.
ffmpeg -hide_banner -y \\
'''
s=hdr
for name,sr,lead in V: s+=f' -f g723_1 -i "data:,{text(lead)}" \\\n'
s+=' -f g723_1 -i "data:,bool'+'o'*129+'" \\\n'
s+=' -f g723_1 -i "data:,'+text(0)*32+'" \\\n'
rates=[792,792,792,1584,1584,1584,1584,396,198,12672]
gain=[1.0,1.0,1.0,0.5,0.5,0.5,0.5,1.0,1.0,0.12]
panL=[0.85,0.85,0.85,0.5,0.95,0.5,0.95,0.7,0.7,1.0]; panR=[0.6,0.6,0.6,0.95,0.5,0.95,0.5,0.7,0.7,0.3]
fc=' -filter_complex "\n'
for i,sr in enumerate(rates):
    fc+=f" [{i}]asetrate={sr},aresample=48000,aformat=channel_layouts=mono,asetpts=N/SR/TB,highpass=f=30,{'adelay=50900,' if i==9 else ''}volume={gain[i]*15:.2f},asplit[a{i}][b{i}0];[b{i}0]{'anull' if i==8 else 'afreqshift=shift=0.28'}[b{i}];[a{i}]volume={panL[i]}[l{i}];[b{i}]volume={panR[i]}[r{i}];\n"
n=len(rates)
fc+=' '+''.join(f'[l{i}]' for i in range(n))+f'amix=inputs={n}:normalize=0:duration=longest[L];\n'
fc+=' '+''.join(f'[r{i}]' for i in range(n))+f'amix=inputs={n}:normalize=0:duration=longest[R];\n'
fc+=' [L][R]amerge=inputs=2,atrim=end=162,afade=t=out:st=150:d=12,volume=1.25,alimiter=level=0:limit=0.8:attack=20:release=200[out]" -map "[out]" "$@"\n'
open('../pieces/205-organum.sh','w').write(s+fc)
