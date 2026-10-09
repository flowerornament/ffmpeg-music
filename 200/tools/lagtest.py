import numpy as np, sys
from gsmline import dec
throat=sys.argv[1] if len(sys.argv)>1 else 'lezeh'
amp=sys.argv[2] if len(sys.argv)>2 else 'p'
fill=sys.argv[3] if len(sys.argv)>3 else 'hello'
for p in 'QUYa_eimquy':
    s=throat+(p+amp+fill)*4; s=s[:30]
    x=dec(((s+'\n# ')*40))[160*20:]
    X=np.abs(np.fft.rfft(x*np.hanning(len(x)))); f=np.fft.rfftfreq(len(x),1/8000)
    X[f<60]=0
    # harmonic sum f0 estimate in 100..220
    cands=np.arange(100,220,0.25); hs=[sum(np.interp(k*c,f,X) for k in range(1,6)) for c in cands]
    print(p, 'lag',ord(p)>>1, f"expect {8000/(ord(p)>>1):6.1f}  hps {cands[int(np.argmax(hs))]:6.1f}  peak {f[np.argmax(X)]:6.1f}  rms {20*np.log10(np.sqrt(np.mean(x**2))):5.1f}")
