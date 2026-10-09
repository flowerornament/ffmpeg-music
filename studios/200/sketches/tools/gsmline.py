import sys, subprocess, numpy as np
# decode a list of 33-byte lines (each given as 32 chars; '\n' appended) once each, report rms per 5ms subframe
def dec(text, sr=8000, fmt='gsm'):
    r=subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-f',fmt,'-sample_rate',str(sr),'-i','-','-f','s16le','-ac','1','-'],input=text.encode('latin1'),capture_output=True)
    return np.frombuffer(r.stdout,dtype=np.int16).astype(float)/32768
if __name__=='__main__':
    for l in sys.argv[1:]:
        assert len(l)==32, (len(l),l)
        x=dec((l+'\n')*4)[160*3:160*4]
        sub=[20*np.log10(np.sqrt(np.mean(x[i*40:(i+1)*40]**2))+1e-9) for i in range(4)]
        print(f"{l!r} " + ' '.join(f"{s:6.1f}" for s in sub))
