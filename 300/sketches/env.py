#!/usr/bin/env python3
# env.py file freq start dur -> dB envelope at freq, 20 ms Goertzel windows
import sys,subprocess,struct,math
f=sys.argv[1]; fr=float(sys.argv[2]); ss=sys.argv[3]; d=sys.argv[4]; sr=48000
raw=subprocess.run(["ffmpeg","-v","error","-ss",ss,"-t",d,"-i",f,"-ac","1","-ar","48000","-f","f32le","-"],capture_output=True).stdout
x=struct.unpack("<%df"%(len(raw)//4),raw); W=960; out=[]
for s in range(0,len(x)-W,W):
    c=2*math.cos(2*math.pi*fr/sr); a=b=0.0
    for v in x[s:s+W]: a,b=v+c*a-b,a
    p=a*a+b*b-c*a*b; out.append("%d"%round(10*math.log10(p/W/W+1e-12)))
print(" ".join(out))
