# search 5-letter "throats" (GSM LAR bytes 0-4): decode with a fixed excitation body, report rms + spectral centroid + peak
import random, numpy as np, sys
from gsmline import dec
random.seed(int(sys.argv[1]) if len(sys.argv)>1 else 2)
b=[' ']*27
for i in (0,7,14,21): b[i]='m'; b[i+1]='p'
body=sys.argv[2] if len(sys.argv)>2 else ''.join(b) # 27 chars: lag/amp positions 5,6 / 12,13 / 19,20 / 26,27 (frame-relative)
assert len(body)==27
L='abcdefghijklmnopqrstuvwxyz'
cands=[''.join(random.choice(L) for _ in range(5)) for _ in range(400)]
text=''.join((c+body+'\n')*8 for c in cands)
x=dec(text)
f=np.fft.rfftfreq(160*4,1/8000)
out=[]
for i,c in enumerate(cands):
    seg=x[(i*8+4)*160:(i*8+8)*160]
    rms=20*np.log10(np.sqrt(np.mean(seg**2))+1e-9)
    S=np.abs(np.fft.rfft(seg*np.hanning(len(seg))))
    cen=np.sum(f*S)/np.sum(S); pk=f[np.argmax(S)]
    out.append((rms,cen,pk,c))
ok=[o for o in out if -30<o[0]<-8]
ok.sort(key=lambda o:o[1])
for o in ok[::max(1,len(ok)//25)]: print(f"{o[3]} rms={o[0]:5.1f} cen={o[1]:6.0f} pk={o[2]:5.0f}")
print(len(ok),'usable of',len(out))
