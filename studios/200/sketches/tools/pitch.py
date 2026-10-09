import sys, subprocess, numpy as np
def decode(word, fmt='g729', loops=99, sr=8000):
    r = subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-stream_loop',str(loops),'-f',fmt,'-i','data:,'+word,'-f','s16le','-ac','1','-ar',str(sr),'-'],capture_output=True)
    return np.frombuffer(r.stdout,dtype=np.int16).astype(float)/32768
def analyze(x, sr=8000):
    if len(x) < sr//2: return None
    y = x[len(x)//2:]
    rms = np.sqrt(np.mean(y**2))+1e-12
    Y = np.abs(np.fft.rfft(y*np.hanning(len(y)), 1<<16))
    f = np.fft.rfftfreq(1<<16, 1/sr)
    # autocorr f0
    ac = np.correlate(y[:2000], y[:2000], 'full')[1999:]
    lo, hi = 20, 400
    lag = lo + np.argmax(ac[lo:hi]); f0 = sr/lag
    clar = ac[lag]/ac[0] if ac[0]>0 else 0
    pk = f[np.argsort(Y)[-5:][::-1]]
    return 20*np.log10(rms), f0, clar, pk
if __name__ == '__main__':
    fmt = sys.argv[1]
    for w in sys.argv[2:]:
        a = analyze(decode(w, fmt))
        if a: print(f"{w!r:16} {a[0]:6.1f}dB f0={a[1]:7.2f} clar={a[2]:.2f} peaks={np.round(a[3],1)}")
