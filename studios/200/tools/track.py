import sys, subprocess, numpy as np
# track.py TEXT : peak frequency of g723_1 decode per 0.25 s
t=sys.argv[1]
r=subprocess.run(['ffmpeg','-v','error','-f','g723_1','-i','data:,'+t,'-f','f32le','-'],capture_output=True)
x=np.frombuffer(r.stdout,dtype=np.float32); N=2000
f=np.fft.rfftfreq(8192,1/8000); out=[]
for i in range(0,len(x)-N,N):
    S=np.abs(np.fft.rfft(x[i:i+N]*np.hanning(N),8192)); S[f<40]=0; out.append(f"{f[np.argmax(S)]:.0f}/{20*np.log10(S.max()+1e-9):.0f}")
print(' '.join(out))
