import sys, subprocess, numpy as np
# probe.py fmt reps word...  : decode word repeated `reps` times (literal repetition) and analyze
from pitch import analyze
fmt=sys.argv[1]; reps=int(sys.argv[2])
for w in sys.argv[3:]:
    r=subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-f',fmt,'-i','data:,'+w*reps,'-f','s16le','-ac','1','-ar','8000','-'],capture_output=True)
    x=np.frombuffer(r.stdout,dtype=np.int16).astype(float)/32768
    a=analyze(x)
    print(f"{w!r:30} n={len(x)} " + (f"{a[0]:6.1f}dB f0={a[1]:7.2f} clar={a[2]:.2f} peaks={np.round(a[3],1)}" if a else r.stderr.decode()[:200]))
