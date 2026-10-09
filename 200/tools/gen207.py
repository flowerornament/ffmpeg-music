# writes ../pieces/207-front-page.sh from ../README (byte offsets are literal in the score)
R=open('../README','rb').read()
lines=R.split(b'\n')[:-1]
offs=[]; o=0
for l in lines:
    offs.append((o,len(l)+1)); o+=len(l)+1
body=list(zip(lines,offs))                # every line of the page
dur=[1.5,.75,.75,1.5,.75,.75,1.5,.75,1.5,.75,.75,.75,2.25,.75,1.5,.75,.75,1.5,.75,.75,.75,.75,4.5]
assert len(dur)==len(body)
P1=sum(dur)
hdr=f'''#!/bin/sh
# 207 — FRONT PAGE (overture: the record's README sings itself)
#
# 200/README is the front page of UNTRANSMITTED, and it is also this
# piece's score. Each line of it was counted to the byte: read by the DFPWM
# decoder at 96 kHz and held, a line of L bytes (newline included) sings 12000/L Hz,
# over the 12 kHz whine of the byte clock. Down the page the line lengths are
#   60 48 40 30 32 36 40 | 45 36 40 48 54 | 60 48 40 36 40 45 48 54 60
#   do mi sol do ti la sol  fa la sol mi re   do mi sol la sol fa mi re do
# and the two empty lines are rests. So the page you read before pressing play is a
# hymn tune, and its ragged right edge is the melody upside down.
# First time: the tune alone ({P1:.2f} s). Second time with a fifth and an octave below
# - the same held lines read at 64 and 48 kHz. Parallel organum works here, where it
# failed in 205, because here pitch is length, not history.
# The README is found from this file's own path: ${{0%/pieces/*}}/README.
ffmpeg -hide_banner -y \\
'''
s=hdr; inputs=[]
for i,(l,(o,n)) in enumerate(body):
    if n==1: inputs.append(None); continue
    inputs.append(len([x for x in inputs if x is not None]))
    s+=f' -stream_loop 3 -f dfpwm -sample_rate 96000 -i "subfile,,start,{o},end,{o+n},,:${{0%/pieces/*}}/README" \\\n'
fc=' -filter_complex "\n'
voices={'m1':(None,1.0),'m2':(None,1.0),'f2':(64000,0.7),'o2':(48000,0.8)}
segs={v:[] for v in voices}
for i,(l,(o,n)) in enumerate(body):
    d=dur[i]; k=inputs[i]
    if k is None:
        for v in voices: segs[v].append(f"anullsrc=r=48000:cl=mono:d={d}")
        continue
    P=8*n
    fc+=f" [{k}]atrim=start_sample={3*P}:end_sample={4*P},asetpts=N/SR/TB,aloop=loop=-1:size={P},atrim=end_sample={P*2000},aformat=channel_layouts=mono,asplit=4[h{k}m1][h{k}m2][h{k}f2][h{k}o2];\n"
    for v,(rate,g) in voices.items():
        tr=f"asetrate={rate}," if rate else ""
        fc+=f" [h{k}{v}]{tr}aresample=48000,atrim=end={d},afade=t=in:d=0.03,afade=t=out:st={d-0.06:.2f}:d=0.06,volume={g},aformat=sample_fmts=fltp:channel_layouts=mono[s{k}{v}];\n"
        segs[v].append(f"[s{k}{v}]")
for v in voices:
    parts=[]
    for j,x in enumerate(segs[v]):
        if x.startswith('anullsrc'):
            fc+=f" {x},aformat=sample_fmts=fltp:channel_layouts=mono[r{v}{j}];\n"; parts.append(f"[r{v}{j}]")
        else: parts.append(x)
    fc+=f" {''.join(parts)}concat=n={len(parts)}:v=0:a=1[{v}];\n"
fc+=f" anullsrc=r=48000:cl=mono:d={P1},aformat=sample_fmts=fltp:channel_layouts=mono,asplit=2[z1][z2];\n"
fc+=" [m1][m2]concat=n=2:v=0:a=1,pan=stereo|c0=0.8*c0|c1=0.8*c0[M];\n"
fc+=" [z1][f2]concat=n=2:v=0:a=1,pan=stereo|c0=0.75*c0|c1=0.35*c0[F];\n"
fc+=" [z2][o2]concat=n=2:v=0:a=1,pan=stereo|c0=0.35*c0|c1=0.75*c0[O];\n"
fc+=" [M][F][O]amix=inputs=3:normalize=0,highpass=f=40,treble=g=-6:f=9000,aecho=0.8:0.5:211|337:0.25|0.18,apad=pad_dur=2,volume=1.3,alimiter=level=0:limit=0.8:attack=5:release=100[out]\" -map \"[out]\" \"$@\"\n"
open('../pieces/207-front-page.sh','w').write(s+fc)
print('pass length',P1)
