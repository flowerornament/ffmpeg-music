# sidcompose.py : greedy search for a sentence of G.723.1 SID words whose comfort-noise whistles follow a target melody.
# usage: sidcompose.py FIRSTWORD "r1 r2 r3 ..."   (ratios of target pitch to the first word's pitch, as floats or a/b)
# The SID spectrum is predictively coded, so each word's pitch depends on the whole sentence before it:
# for every step we decode history+candidate for every candidate word and keep the closest sharp whistle.
import sys, re, subprocess, numpy as np
from fractions import Fraction
from concurrent.futures import ThreadPoolExecutor
K=14
ws=sorted({w.strip().lower() for w in open('/usr/share/dict/words') if re.fullmatch(r'[bfjnrvz][a-z]{3}',w.strip().lower())})
f=np.fft.rfftfreq(1<<14,1/8000)
def last_pitch(words):
    t=''.join(w+'o'*(K-1) for w in words)
    x=np.frombuffer(subprocess.run(['ffmpeg','-v','error','-f','g723_1','-i','data:,'+t,'-f','f32le','-'],capture_output=True).stdout,dtype=np.float32)
    seg=x[-(K-4)*240:]
    S=np.abs(np.fft.rfft(seg*np.hanning(len(seg)),1<<14))**2; S[f<40]=0
    k=np.argmax(S); db=10*np.log10(S+1e-20)
    return float(f[k]), float(db[k]-np.median(db))
if __name__=='__main__':
  first=sys.argv[1]; R=[float(Fraction(r)) for r in sys.argv[2].split()]
  hist=[first]; p0,_=last_pitch(hist); print(first, round(p0,1), file=sys.stderr)
  out=[(first,p0,0.0)]
  for r in R:
      tgt=p0*r
      with ThreadPoolExecutor(8) as ex: res=list(ex.map(lambda w:(w,)+last_pitch(hist+[w]), ws))
      res=[x for x in res if x[2]>30 and x[0]!=hist[-1]]
      w,p,s=min(res,key=lambda x:abs(np.log2(x[1]/tgt)))
      hist.append(w); out.append((w,p,1200*np.log2(p/tgt)))
      print(w, round(p,1), f"{1200*np.log2(p/tgt):+.0f}c", file=sys.stderr)
  print(' '.join(w for w,_,_ in out))
  print(' '.join(f"{p/p0:.4f}" for _,p,_ in out))
