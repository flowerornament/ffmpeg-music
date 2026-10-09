import sys,subprocess,array,math
# env.py file start dur [channel] [ms]: RMS envelope in dB per block. Locates hits in time
# (e.g. low-pass first to see where the kicks/bass land relative to the beat grid).
f,st,du=sys.argv[1],float(sys.argv[2]),float(sys.argv[3]); ch=int(sys.argv[4]) if len(sys.argv)>4 else 0; ms=float(sys.argv[5]) if len(sys.argv)>5 else 5
raw=subprocess.run(['ffmpeg','-v','error','-ss',str(st),'-t',str(du),'-i',f,'-f','f32le','-ac','2','-ar','48000','-'],capture_output=True).stdout
a=array.array('f'); a.frombytes(raw); x=a[ch::2]; b=int(48*ms)
for i in range(0,len(x)-b+1,b):
  seg=x[i:i+b]; r=math.sqrt(sum(v*v for v in seg)/b); db=20*math.log10(r+1e-9)
  print(f"{st+i/48000:7.3f} {db:6.1f} {'#'*max(0,int((db+60)/2))}")
