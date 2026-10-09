#!/usr/bin/env python3
# peaks.py file [start_s] [n_peaks] -> strongest spectral peaks (Hz, dB) of a 32768-sample mono window
import sys, subprocess, struct, cmath, math
f=sys.argv[1]; ss=float(sys.argv[2]) if len(sys.argv)>2 else 1.0; k=int(sys.argv[3]) if len(sys.argv)>3 else 12
N=32768; sr=48000
raw=subprocess.run(["ffmpeg","-v","error","-ss",str(ss),"-i",f,"-ac","1","-ar",str(sr),"-f","f32le","-frames:a","1","-af","asetnsamples=%d"%N,"-"],capture_output=True).stdout
x=list(struct.unpack("<%df"%(len(raw)//4),raw))[:N]; x+= [0.0]*(N-len(x))
x=[v*(0.5-0.5*math.cos(2*math.pi*i/N)) for i,v in enumerate(x)]
def fft(a):
    n=len(a)
    if n==1: return a
    e=fft(a[0::2]); o=fft(a[1::2])
    t=[cmath.exp(-2j*math.pi*i/n)*o[i] for i in range(n//2)]
    return [e[i]+t[i] for i in range(n//2)]+[e[i]-t[i] for i in range(n//2)]
X=[abs(c) for c in fft(x)[:N//2]]
pk=[i for i in range(2,N//2-1) if X[i]>X[i-1] and X[i]>=X[i+1]]
pk.sort(key=lambda i:-X[i]); m=max(X) or 1
def note(fq):
    if fq<=0: return ""
    s=12*math.log2(fq/440)+69; n=round(s); return "%s%d%+d"%("C C# D D# E F F# G G# A A# B".split()[n%12],n//12-1,round((s-n)*100))
for i in sorted(pk[:k]): print("%8.1f Hz %6.1f dB  %s"%(i*sr/N,20*math.log10(X[i]/m),note(i*sr/N)))
