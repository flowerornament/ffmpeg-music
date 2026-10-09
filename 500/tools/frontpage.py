# frontpage.py — generates 500/README, the plain-text front page: the paragraph through the
# room, and three-row text spectrograms of each track (beginning, middle, end) from out/*.mp3.
# run from the repo root after rendering: uv run --with numpy python 500/tools/frontpage.py
import subprocess, numpy as np, random, glob
g0="a knock, a breath, a melody you will never hear, a manual reading itself aloud, the bytes of the program that made this, sent into a room built from arithmetic and played back into it again and again until nothing is left but what a room keeps"
w=g0.split(' '); n=len(w); keep={n-4,n-3,n-2,n-1}
order=[i for i in range(n) if i not in keep]; random.seed(510); random.shuffle(order)
order.sort(key=lambda i: (('room' in w[i]) or ('again' in w[i]) or ('it'==w[i]),))
gens=[set(range(n))]; alive=set(range(n)); pos=0
for s in [0.2,0.25,0.3,0.35,0.45,0.6,1.0]:
    k=round(s*(len(order)-pos)) if s<1 else len(order)-pos
    for i in order[pos:pos+k]: alive.discard(i)
    pos+=k; gens.append(set(alive))
def render(a):
    lines=[];cur=''
    for i,x in enumerate(w):
        tok=(x if i in a else ' '*len(x))
        if len(cur)+len(tok)+1>64: lines.append(cur.rstrip()); cur=''
        cur+=tok+' '
    lines.append(cur.rstrip()); return lines
labels=["the voice","once through the room","twice","4 times","8 times","16 times","32 times","64 times"]
out=[]; P=lambda s='': out.append(s)
P("EIGENROOM"); P("What a Room Keeps"); P()
for gi,a in enumerate(gens):
    lab=f" {labels[gi]} "
    P("    "+"─"*4+lab+"─"*(60-len(lab))); P()
    for l in render(a): P("    "+l if l.strip() else "")
    P()
P()
F0=27.5; COLS=64; OCT=8; edges=F0*2**(np.arange(COLS+1)/COLS*OCT)
ramp=[(-3,'#'),(-8,'*'),(-14,'+'),(-20,'='),(-27,'-'),(-34,':'),(-42,'·')]
def glyph(d):
    for th,c in ramp:
        if d>=th: return c
    return ' '
def rows(f):
    raw=subprocess.run(["ffmpeg","-v","error","-i",f,"-ac","1","-ar","16000","-f","f32le","-"],capture_output=True).stdout
    x=np.frombuffer(raw,dtype=np.float32); N=8192; wdw=np.hanning(N); fr=np.fft.rfftfreq(N,1/16000)
    frames=np.array([np.abs(np.fft.rfft(x[i:i+N]*wdw))**2 for i in range(0,len(x)-N,4096)])
    R=[]
    for part in np.array_split(frames,3):
        Pm=part.mean(0); R.append(np.array([Pm[(fr>=a)&(fr<b)].max() if ((fr>=a)&(fr<b)).any() else 0 for a,b in zip(edges[:-1],edges[1:])]))
    top=max(r.max() for r in R)
    return [''.join(glyph(10*np.log10(v/top+1e-20)) for v in r).rstrip() for r in R]
T=[("510","room tone","","1:00","one room, knocked in a corner, at a wall, at the centre"),
   ("501","power","iteration","2:02","the manual read into the room until only C# G# B remain"),
   ("503","floor plan","","2:30","four rooms shaped like chords, played as a drum kit"),
   ("502","overtone","lessons","2:48","a song you never hear, sung back in a drone's overtones"),
   ("504","libavfilter","sung","1:42","the library these filters live in, read as bytes, in A"),
   ("506","coincidence","","2:56","the upmixer keeps only what two voices share"),
   ("508","terzo suono","","3:04","the correlator keeps only their difference: a bass"),
   ("509","above and","below","2:30","both reports at once; the duet itself is missing"),
   ("505","tesseract","","3:10","a four-dimensional room, walked through"),
   ("511","eigenvector","","1:06","the first knock, through the room 64 times: B over E")]
M=" "*15
P("what each room keeps"); P()
ruler=list(" "*65)
for k,lab in enumerate(["27","55","110","220","440","880","1.7k","3.5k"]):
    for j,c in enumerate(lab):
        if 8*k+j<65: ruler[8*k+j]=c
P("hz".ljust(15)+''.join(ruler).rstrip())
P(M+"|·······"*8+"|"); P()
for i,(num,t1,t2,dur,desc) in enumerate(T,1):
    r=rows(glob.glob(f"500/out/{num}-*.mp3")[0])
    left=[f"{i:>2} {t1}", f"   {t2}" if t2 else f"   {dur}", f"   {dur}" if t2 else ""]
    for L,row in zip(left,r): P((f"{L:<15}"+row).rstrip())
    P(M+desc); P()
P(M+"each track is three rows: its beginning, middle and end.")
P(M+"columns are pitch, A0 to A8, eight to the octave.")
P(M+"the darker the glyph, the more of that pitch the room kept.")
P(M+"read 2 and 10 from top to bottom: that is the whole idea.")
P(); P()
for l in ["ten pieces, 22 minutes 48 seconds. each one is a single ffmpeg command,",
"written out and run once. nothing was recorded. the sounds are made from",
"arithmetic, or read from files that were never meant to be sound, and",
"passed through rooms: rooms built from the formula for a box of air,",
"rooms built from filters that learn, rooms built from machines that",
"listen and decide what to keep. the composer never heard any of it."]: P(l)
P(); P()
P("scripts/play.sh 500                  the record, in the order of TRACKLIST")
P("scripts/render.sh 500/pieces/5*.sh   render every piece into out/")
P(); P()
for l in ["TRACKLIST    play order; 507-dead-air.sh is the outtake",
"pieces/      the scores: one command each, with a header that says what",
"             room it is and why it keeps what it keeps",
"found/       the manual page track 2 reads aloud",
"ESSAY        liner notes: rooms, eigenvectors, listening machines",
"JOURNAL      the studio diary, dead ends included",
"HANDOFF      a letter to whoever works here next",
"sketches/    experiments, and the tools used in place of ears"]: P(l)
P(); P()
P("EIGENROOM · claude · studio 500 · october 2026")
P("at the invitation of a listener · ffmpeg 9.0.1 · every filter is a room")
P(); P()
P(" "*50+"what a room keeps")
open("500/README","w").write("\n".join(out)+"\n")
print("maxlen",max(len(l) for l in out))
