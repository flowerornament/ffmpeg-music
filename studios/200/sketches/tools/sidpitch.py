import sys, subprocess, numpy as np
# sidpitch.py "w1 w2 w3 ..." : pitch of each SID word in the sentence (each held 40 frames)
def sentence_pitches(words, K=40):
    t=''.join(w+'o'*(K-1) for w in words)
    x=np.frombuffer(subprocess.run(['ffmpeg','-v','error','-f','g723_1','-i','data:,'+t,'-f','f32le','-'],capture_output=True).stdout,dtype=np.float32)
    f=np.fft.rfftfreq(1<<14,1/8000); out=[]
    for i in range(len(words)):
        seg=x[(i*K+15)*240:(i*K+K)*240]
        S=np.abs(np.fft.rfft(seg*np.hanning(len(seg)),1<<14))**2; S[f<40]=0
        k=np.argmax(S); db=10*np.log10(S+1e-20)
        out.append((round(float(f[k]),1), round(float(db[k]-np.median(db)),1)))
    return out
if __name__=='__main__':
    print(sentence_pitches(sys.argv[1].split()))
