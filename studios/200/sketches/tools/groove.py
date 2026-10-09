import sys, subprocess, numpy as np
# groove.py file start dur : onset-strength autocorrelation peaks (beat periods) + pulse clarity
f,ss,d=sys.argv[1],sys.argv[2],sys.argv[3]
x=np.frombuffer(subprocess.run(['ffmpeg','-v','error','-ss',ss,'-t',d,'-i',f,'-ac','1','-ar','16000','-f','f32le','-'],capture_output=True).stdout,dtype=np.float32)
H=160; N=1024
fr=[np.abs(np.fft.rfft(x[i:i+N]*np.hanning(N))) for i in range(0,len(x)-N,H)]
S=np.log1p(np.array(fr)*10)
flux=np.maximum(0,np.diff(S,axis=0)).sum(1); flux-=flux.mean()
ac=np.correlate(flux,flux,'full')[len(flux)-1:]; ac/=ac[0]
lags=np.arange(len(ac))*H/16000
idx=[i for i in range(5,min(len(ac)-1,400)) if ac[i]>ac[i-1] and ac[i]>ac[i+1]]
idx=sorted(idx,key=lambda i:-ac[i])[:6]
print(' '.join(f"{lags[i]:.3f}s({ac[i]:.2f})" for i in sorted(idx)))
