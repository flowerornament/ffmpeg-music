# usage: peaks.py file.wav [start_s] [dur_s] [n]  -> strongest spectral peaks (Hz, dB, note)
import sys, subprocess, numpy as np
f=sys.argv[1]; ss=float(sys.argv[2]) if len(sys.argv)>2 else 0; d=float(sys.argv[3]) if len(sys.argv)>3 else 2; N=int(sys.argv[4]) if len(sys.argv)>4 else 14
raw=subprocess.run(["ffmpeg","-v","error","-ss",str(ss),"-t",str(d),"-i",f,"-ac","1","-ar","48000","-f","f32le","-"],capture_output=True).stdout
x=np.frombuffer(raw,np.float32); 
w=1<<int(np.log2(min(len(x),65536))); hop=w//2; S=np.zeros(w//2+1)
for i in range(0,len(x)-w+1,hop): S+=np.abs(np.fft.rfft(x[i:i+w]*np.hanning(w)))**2
S=10*np.log10(S+1e-20); S-=S.max(); fr=np.fft.rfftfreq(w,1/48000)
pk=[i for i in range(2,len(S)-2) if S[i]==S[i-2:i+3].max() and fr[i]>20]
pk=sorted(pk,key=lambda i:-S[i])[:N]
nm="C C# D D# E F F# G G# A A# B".split()
for i in sorted(pk):
  m=69+12*np.log2(fr[i]/440); print(f"{fr[i]:8.1f} Hz {S[i]:6.1f} dB  {nm[int(round(m))%12]}{int(round(m))//12-1} {100*(m-round(m)):+.0f}c")
