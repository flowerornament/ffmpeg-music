#!/usr/bin/env python3
# lag.py stereo.wav -> lag (samples) of ch0 relative to ch1 maximizing correlation, and residual ratio
import sys,subprocess,struct
raw=subprocess.run(["ffmpeg","-v","error","-i",sys.argv[1],"-f","f32le","-"],capture_output=True).stdout
v=struct.unpack("<%df"%(len(raw)//4),raw); a=v[0::2]; b=v[1::2]
s0=48000; L=8000
best=None
for lag in range(-3000,3000):
    c=sum(a[s0+i+lag]*b[s0+i] for i in range(0,L,4))
    if best is None or c>best[1]: best=(lag,c)
lag=best[0]
e=sum((a[s0+i+lag]-b[s0+i])**2 for i in range(L)); p=sum(b[s0+i]**2 for i in range(L))
print("lag",lag,"residual/orig dB %.1f"%(10*__import__('math').log10(e/p+1e-12)))
