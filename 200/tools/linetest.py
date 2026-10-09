import numpy as np, sys
from gsmline import dec
# each arg: a 30-char line body; file text = "# "+body+"\n", looped; report rms, f0 by hps over 20..2000 and spectral peak
for b in sys.argv[1:]:
    assert len(b)==30,(len(b),b)
    x=dec(("# "+b+"\n")*60)[160*30:]
    X=np.abs(np.fft.rfft(x*np.hanning(len(x)))); f=np.fft.rfftfreq(len(x),1/8000); X[f<30]=0
    top=f[np.argsort(X)[-6:]]
    print(f"{b!r} rms {20*np.log10(np.sqrt(np.mean(x**2))+1e-9):6.1f}  peaks {np.sort(np.round(top))}")
