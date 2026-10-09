# sidsearch.py HISTORY TARGET_HZ : which SID word, said after HISTORY, whistles nearest TARGET (G.723.1 LSPs are predicted from the previous frame)
import sys, re, subprocess, numpy as np
from concurrent.futures import ThreadPoolExecutor
hist=sys.argv[1]; target=float(sys.argv[2]); K=60
ws=sorted({w.strip().lower() for w in open('/usr/share/dict/words') if re.fullmatch(r'[bfjnrvz][a-z]{3}',w.strip().lower())})
f=np.fft.rfftfreq(1<<15,1/8000)
def meas(w):
    r=subprocess.run(['ffmpeg','-v','error','-f','g723_1','-i','data:,'+hist+w+'o'*K,'-f','f32le','-'],capture_output=True)
    x=np.frombuffer(r.stdout,dtype=np.float32)[-240*(K-20):]
    S=np.abs(np.fft.rfft(x*np.hanning(len(x)),1<<15))**2; S[f<40]=0
    k=np.argmax(S); db=10*np.log10(S+1e-20)
    return (abs(1200*np.log2(f[k]/target)), w, round(float(f[k]),1), round(float(db[k]-np.median(db)),1))
with ThreadPoolExecutor(8) as ex: res=list(ex.map(meas,ws))
res=[r for r in res if r[3]>38]; res.sort()
for r in res[:12]: print(f"{r[1]} {r[2]}Hz {r[0]:.0f}c sharp={r[3]}")
