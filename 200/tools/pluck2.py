import subprocess, numpy as np, sys
# G.723.1 6.3k frame "t" + 23 chars, then 8 erasures; vary char at index 3 & 4 and measure tail pitch
base=list(sys.argv[1] if len(sys.argv)>1 else "the cat sat on the mat..")
def meas(fr):
    r=subprocess.run(['ffmpeg','-v','error','-f','g723_1','-i','data:,'+fr+'o'*8,'-f','f32le','-'],capture_output=True)
    x=np.frombuffer(r.stdout,dtype=np.float32)
    seg=x[240:240*4]; 
    ac=np.correlate(seg,seg,'full')[len(seg)-1:]; lag=18+np.argmax(ac[18:150])
    X=np.abs(np.fft.rfft(seg*np.hanning(len(seg)),1<<14)); f=np.fft.rfftfreq(1<<14,1/8000)
    lv=[20*np.log10(np.sqrt(np.mean(x[i*240:(i+1)*240]**2))+1e-9) for i in range(6)]
    return 8000/lag, f[np.argmax(X)], lv
for c3 in "aeimquy AEIMQUY 048<":
    for c4 in "ab":
        b=base[:]; b[3]=c3; b[4]=c4; fr=''.join(b)
        f0,pk,lv=meas(fr)
        print(repr(c3+c4), f"lag-f0 {f0:6.1f} peak {pk:6.0f}", ' '.join(f"{v:.0f}" for v in lv))
