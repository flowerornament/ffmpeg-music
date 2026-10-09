import json, subprocess, numpy as np, sys
# precise whistle frequency + 2nd peak for given SID words (each held 8 s)
ws=sys.argv[1:] or [d['w'] for d in json.load(open('sid.json')) if d['sharp']>40]
K=266
r=subprocess.run(['ffmpeg','-v','error','-f','g723_1','-i','data:,'+''.join(w+'o'*(K-1) for w in ws),'-f','f32le','-'],capture_output=True)
x=np.frombuffer(r.stdout,dtype=np.float32)
N=1<<16; f=np.fft.rfftfreq(N,1/8000)
out={}
for i,w in enumerate(ws):
    seg=x[(i*K+5)*240:(i*K+5)*240+N]
    S=np.abs(np.fft.rfft(seg*np.hanning(len(seg)),N))**2; S[f<40]=0
    k=np.argmax(S); 
    # parabolic interp
    a,b,c=np.log(S[k-1:k+2]+1e-20); p=0.5*(a-c)/(a-2*b+c)
    fk=(k+p)*(f[1]-f[0])
    S2=S.copy(); S2[max(0,k-200):k+200]=0; k2=np.argmax(S2)
    out[w]=(round(float(fk),2), round(float(f[k2]),1), round(float(10*np.log10(S[k]/S2[k2])),1))
    print(w, out[w])
json.dump(out,open('sidfine.json','w'))
