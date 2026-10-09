import sys, subprocess, numpy as np
# pluck.py "24-byte frame" [n_o] : decode frame + n 'o' (erasures), report tail f0 and per-frame level
for fr in sys.argv[1:]:
    n=40
    r=subprocess.run(['ffmpeg','-v','error','-f','g723_1','-i','data:,'+fr+'o'*n,'-f','s16le','-'],capture_output=True)
    x=np.frombuffer(r.stdout,dtype=np.int16).astype(float)/32768
    lv=[20*np.log10(np.sqrt(np.mean(x[i*240:(i+1)*240]**2))+1e-9) for i in range(len(x)//240)]
    seg=x[240*2:240*8]; ac=np.correlate(seg,seg,'full')[len(seg)-1:]
    lag=18+np.argmax(ac[18:200]); 
    X=np.abs(np.fft.rfft(seg*np.hanning(len(seg)),8192)); f=np.fft.rfftfreq(8192,1/8000)
    print(f"{fr!r} n={len(x)//240} f0~{8000/lag:6.1f} pk={f[np.argmax(X)]:6.0f} lv:", ' '.join(f"{v:.0f}" for v in lv[:14]))
