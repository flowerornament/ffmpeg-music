import sys, subprocess, numpy as np
# peaks.py file [start] [dur] [n] : strongest spectral peaks (Hz, dB) of a segment
f=sys.argv[1]; ss=sys.argv[2] if len(sys.argv)>2 else '0'; d=sys.argv[3] if len(sys.argv)>3 else '4'; n=int(sys.argv[4]) if len(sys.argv)>4 else 20
r=subprocess.run(['ffmpeg','-v','error','-ss',ss,'-t',d,'-i',f,'-ac','1','-ar','48000','-f','f32le','-'],capture_output=True)
x=np.frombuffer(r.stdout,dtype=np.float32)
X=np.abs(np.fft.rfft(x*np.hanning(len(x)))); fr=np.fft.rfftfreq(len(x),1/48000)
X/=X.max(); pk=[i for i in range(1,len(X)-1) if X[i]>X[i-1] and X[i]>X[i+1] and fr[i]>20]
pk=sorted(pk,key=lambda i:-X[i])[:n]
print(' '.join(f"{fr[i]:.1f}({20*np.log10(X[i]):.0f})" for i in sorted(pk)))
