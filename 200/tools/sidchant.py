# sidchant.py FIRST N SEED : a chant found by walking the SID codebook graph. At each step: every dictionary SID word is
# tried after the sentence so far; keep whistles within TOL cents of a 5-limit just degree (relative to the first word),
# within an octave of the tonic, a step of <= ~5/4 from the previous note, not the previous degree; pick at random (seeded),
# biased toward the tonic as the chant nears its end.
import sys, random, numpy as np
from sidcompose import last_pitch, ws
from concurrent.futures import ThreadPoolExecutor
JI={'1':1,'16/15':16/15,'9/8':9/8,'6/5':6/5,'5/4':5/4,'4/3':4/3,'45/32':45/32,'3/2':3/2,'8/5':8/5,'5/3':5/3,'9/5':9/5,'15/8':15/8}
LAT={}
for k,v in JI.items():
    LAT[k]=v; LAT[k+"/2"]=v/2
LAT['2']=2.0
TOL=12
first=sys.argv[1]; N=int(sys.argv[2]); random.seed(int(sys.argv[3]))
hist=[first]; p0,_=last_pitch(hist); seq=[(first,'1',1.0,0.0)]; prev=1.0
for step in range(N):
    with ThreadPoolExecutor(8) as ex: res=list(ex.map(lambda w:(w,)+last_pitch(hist+[w]), ws))
    cands=[]
    for w,p,s in res:
        if s<32 or w==hist[-1]: continue
        r=p/p0
        for name,v in LAT.items():
            c=1200*np.log2(r/v)
            if abs(c)<=TOL and v!=prev and 0.55<=v/prev<=1.9:
                cands.append((name,v,c,w,p))
    if not cands: print('stuck', file=sys.stderr); break
    endpull = step>N-4
    if endpull:
        cands.sort(key=lambda x:abs(np.log2(x[1])))
        pick=cands[0]
    else:
        degs=sorted({x[0] for x in cands}); dn=random.choice(degs)
        pick=min([x for x in cands if x[0]==dn], key=lambda x:abs(x[2]))
    name,v,c,w,p=pick; hist.append(w); seq.append((w,name,v,c)); prev=v
    print(f"{w} {name} {p:.1f} {c:+.0f}c  (choices: {' '.join(sorted({x[0] for x in cands}))})", file=sys.stderr)
print(' '.join(x[0] for x in seq)); print(' '.join(x[1] for x in seq)); print(' '.join(f"{x[3]:+.0f}" for x in seq))
