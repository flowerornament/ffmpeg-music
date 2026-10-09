# sidwalk.py FIRST "deg deg deg ..." : walk the SID codebook graph; at each step take the word whose whistle lands
# in-tune (<= TOL cents) on a JI dorian degree nearest the requested degree. degrees: 0=tonic(first word), 1..6, 7=octave, negatives below.
import sys, re, numpy as np
from sidcompose import last_pitch, ws
from concurrent.futures import ThreadPoolExecutor
TOL=float(sys.argv[3]) if len(sys.argv)>3 else 15
SC=[1,9/8,6/5,4/3,3/2,5/3,9/5]
def deg_ratio(d): o,i=divmod(d,7); return SC[i]*2**o
first=sys.argv[1]; want=[int(x) for x in sys.argv[2].split()]
hist=[first]; p0,_=last_pitch(hist); seq=[(first,0,0.0)]
for d in want:
    with ThreadPoolExecutor(8) as ex: res=list(ex.map(lambda w:(w,)+last_pitch(hist+[w]), ws))
    best=None
    for w,p,s in res:
        if s<30 or w==hist[-1]: continue
        r=p/p0
        for dd in range(-14,15):
            c=1200*np.log2(r/deg_ratio(dd))
            if abs(c)<=TOL:
                score=(abs(dd-d), abs(c), -s)
                if best is None or score<best[0]: best=(score,w,dd,c,p)
    _,w,dd,c,p=best; hist.append(w); seq.append((w,dd,c))
    print(f"want {d:+d} got {dd:+d} {w} {p:.1f} {c:+.0f}c", file=sys.stderr)
print(' '.join(w for w,_,_ in seq)); print(' '.join(str(dd) for _,dd,_ in seq)); print(' '.join(f"{c:+.0f}" for _,_,c in seq))
