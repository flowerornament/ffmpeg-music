# view.py in.wav out.png [fmin] [fmax]  : 1000x400 log-freq spectrogram, adaptive windows, grid at A's, L/R stacked if stereo
import sys, subprocess, numpy as np
f,out=sys.argv[1],sys.argv[2]; fmin=float(sys.argv[3]) if len(sys.argv)>3 else 27.5; fmax=float(sys.argv[4]) if len(sys.argv)>4 else 16000
raw=subprocess.run(["ffmpeg","-v","error","-i",f,"-ac","1","-ar","48000","-f","f32le","-"],capture_output=True).stdout
x=np.frombuffer(raw,np.float32).astype(np.float64); W,H=1000,400; sr=48000
fr=fmin*(fmax/fmin)**(np.arange(H)/(H-1))
img=np.zeros((H,W))
cent=np.linspace(0,len(x)-1,W).astype(int)
for win,lo,hi in [(16384,0,180),(4096,180,1500),(1024,1500,1e9)]:
  rows=np.where((fr>=lo)&(fr<hi))[0]
  if len(rows)==0: continue
  hw=np.hanning(win); bins=np.fft.rfftfreq(win,1/sr)
  for j,c in enumerate(cent):
    s=max(0,c-win//2); seg=x[s:s+win]
    if len(seg)<win: seg=np.pad(seg,(0,win-len(seg)))
    S=np.abs(np.fft.rfft(seg*hw))/win*4
    img[rows,j]=np.interp(fr[rows],bins,S)
db=20*np.log10(img+1e-9); db=np.clip((db+90)/90,0,1)
r=np.clip(db*1.6,0,1); g=np.clip(db*1.6-0.5,0,1); b=np.clip(0.3+db*0.5-np.clip(db*1.6-0.8,0,1),0,1)
rgb=(np.stack([r,g,b],-1)[::-1]*255).astype(np.uint8)
for k in range(-2,12):
  fa=440*2**(k-4)
  if fmin<fa<fmax:
    y=H-1-int(round(np.log(fa/fmin)/np.log(fmax/fmin)*(H-1))); rgb[y,::4]=[80,200,255]
for t in range(0,int(len(x)/sr)+1,10):
  xx=int(t*sr/len(x)*W)
  if xx<W: rgb[::6,xx]=[255,255,255]
hdr=f"P6 {W} {H} 255\n".encode()
subprocess.run(["ffmpeg","-v","error","-y","-f","ppm_pipe","-i","-",out],input=hdr+rgb.tobytes())
