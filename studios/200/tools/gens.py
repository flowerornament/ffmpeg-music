import sys, subprocess, numpy as np
# gens.py file.wav : per-channel (generation) rms, spectral centroid, flatness, and corr with gen0
f=sys.argv[1]
r=subprocess.run(['ffmpeg','-v','error','-i',f,'-f','f32le','-'],capture_output=True)
ch=int(subprocess.run(['ffprobe','-v','error','-show_entries','stream=channels','-of','csv=p=0',f],capture_output=True,text=True).stdout)
x=np.frombuffer(r.stdout,dtype=np.float32).reshape(-1,ch).T
fr=np.fft.rfftfreq(4096,1/16000)
for i,c in enumerate(x):
    S=np.mean([np.abs(np.fft.rfft(c[j:j+4096]*np.hanning(4096)))**2 for j in range(0,len(c)-4096,2048)],axis=0)+1e-15
    cen=np.sum(fr*S)/np.sum(S); flat=np.exp(np.mean(np.log(S)))/np.mean(S)
    print(f"gen{i} rms={10*np.log10(np.mean(c**2)+1e-12):6.1f} cen={cen:6.0f} flat={flat:.3f}")
