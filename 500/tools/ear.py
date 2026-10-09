# ear.py file.wav seg_seconds [npeaks] [fmin] [fmax] : per segment rms, side level, strongest spectral peaks as note names (cents, dB rel. top). Run with: uv run --with numpy python ear.py ...
import sys, subprocess, numpy as np
f=sys.argv[1]; seg=float(sys.argv[2]); npk=int(sys.argv[3]) if len(sys.argv)>3 else 8
fmin=float(sys.argv[4]) if len(sys.argv)>4 else 30; fmax=float(sys.argv[5]) if len(sys.argv)>5 else 5000
raw=subprocess.run(["ffmpeg","-v","error","-i",f,"-ac","2","-ar","48000","-f","f32le","-"],capture_output=True).stdout
x=np.frombuffer(raw,dtype=np.float32).reshape(-1,2); m=x.mean(1); sd=(x[:,0]-x[:,1])/2
names=['C','C#','D','D#','E','F','F#','G','G#','A','A#','B']
def nn(fr):
    mi=69+12*np.log2(fr/440); r=int(round(mi)); c=int(round((mi-r)*100)); return f"{names[r%12]}{r//12-1}{c:+d}"
N=int(seg*48000)
for i in range(0,len(m)-N+1,N):
    s=m[i:i+N]; w=s*np.hanning(len(s)); S=np.abs(np.fft.rfft(w)); fr=np.fft.rfftfreq(len(s),1/48000)
    rms=20*np.log10(np.sqrt(np.mean(s**2))+1e-12); srms=20*np.log10(np.sqrt(np.mean(sd[i:i+N]**2))+1e-12)
    band=(fr>fmin)&(fr<fmax); idx=np.where(band)[0]
    pk=[j for j in idx[1:-1] if S[j]>S[j-1] and S[j]>=S[j+1]]
    pk=sorted(pk,key=lambda j:-S[j])[:npk]; top=S[pk[0]] if pk else 1
    print(f"{i/48000:6.1f}s rms{rms:6.1f} side{srms:6.1f} | "+" ".join(f"{fr[j]:.0f}({nn(fr[j])},{20*np.log10(S[j]/top):.0f})" for j in sorted(pk)))
