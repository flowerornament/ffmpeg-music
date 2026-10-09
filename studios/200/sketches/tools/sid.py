# rank 4-letter words starting with a SID-class letter (b f j n r v z) as G.723.1 comfort-noise colours
import re, subprocess, numpy as np, sys, json
ws=sorted({w.strip().lower() for w in open('/usr/share/dict/words') if re.fullmatch(r'[bfjnrvz][a-z]{3}',w.strip().lower())})
K=12
text=''.join(w+'o'*(K-1) for w in ws)
r=subprocess.run(['ffmpeg','-v','error','-f','g723_1','-i','data:,'+text,'-f','s16le','-'],capture_output=True)
x=np.frombuffer(r.stdout,dtype=np.int16).astype(float)/32768
print('decoded frames',len(x)//240,'expected',len(ws)*K, file=sys.stderr)
f=np.fft.rfftfreq(2048,1/8000)
res=[]
for i,w in enumerate(ws):
    seg=x[(i*K+3)*240:(i*K+K)*240]
    if len(seg)<2048: break
    # average spectrum
    S=np.mean([np.abs(np.fft.rfft(seg[j:j+2048]*np.hanning(2048)))**2 for j in range(0,len(seg)-2048,256)],axis=0)
    S[f<60]=1e-12
    db=10*np.log10(S+1e-12); pk=np.argmax(db); 
    # sharpness: peak minus median in dB ; bandwidth: count bins within 3dB
    bw=np.sum(db>db[pk]-6)*(f[1]-f[0])
    res.append(dict(w=w,f=float(f[pk]),sharp=float(db[pk]-np.median(db)),bw=float(bw),lvl=float(10*np.log10(np.mean(seg**2)+1e-12))))
json.dump(res,open('sid.json','w'))
res.sort(key=lambda d:-d['sharp'])
for d in res[:40]: print(f"{d['w']} f={d['f']:6.0f} sharp={d['sharp']:5.1f} bw={d['bw']:5.0f} lvl={d['lvl']:5.1f}")
