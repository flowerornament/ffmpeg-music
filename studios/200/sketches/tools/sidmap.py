# sidmap.py HISTORY REF_HZ : all whistles reachable after HISTORY, as ratios to REF (sharp ones only), nearest simple JI ratio
import sys, re, subprocess, numpy as np
from fractions import Fraction
from concurrent.futures import ThreadPoolExecutor
hist=sys.argv[1]; ref=float(sys.argv[2]); K=60
ws=sorted({w.strip().lower() for w in open('/usr/share/dict/words') if re.fullmatch(r'[bfjnrvz][a-z]{3}',w.strip().lower())})
f=np.fft.rfftfreq(1<<15,1/8000)
def meas(w):
    r=subprocess.run(['ffmpeg','-v','error','-f','g723_1','-i','data:,'+hist+w+'o'*K,'-f','f32le','-'],capture_output=True)
    x=np.frombuffer(r.stdout,dtype=np.float32)[-240*(K-20):]
    S=np.abs(np.fft.rfft(x*np.hanning(len(x)),1<<15))**2; S[f<40]=0
    k=np.argmax(S); db=10*np.log10(S+1e-20)
    return (round(float(f[k]),1), w, round(float(db[k]-np.median(db)),1))
with ThreadPoolExecutor(8) as ex: res=list(ex.map(meas,ws))
groups={}
for fr,w,s in res:
    if s<38: continue
    groups.setdefault(fr,[]).append(w)
JI=[Fraction(a,b) for a in range(1,17) for b in range(1,17)]
for fr in sorted(groups):
    r=fr/ref; best=min(JI,key=lambda q:abs(1200*np.log2(float(q)/r)))
    print(f"{fr:7.1f} x{r:.4f} ~{best} ({1200*np.log2(r/float(best)):+.0f}c) {' '.join(groups[fr][:6])}")
