import sys, subprocess, numpy as np
lib=sys.argv[1]
nm=subprocess.run(["nm","-n",lib],capture_output=True,text=True).stdout.split("\n")
rows=[l.split() for l in nm if len(l.split())==3 and l.split()[1] in "sSdD"]
rows=[(int(a,16),n) for a,_,n in rows]
# text segment bound
seg=subprocess.run(["otool","-l",lib],capture_output=True,text=True).stdout
import re
tsize=int(re.search(r"segname __TEXT\n\s+vmaddr \S+\n\s+vmsize (\S+)",seg).group(1),16)
data=open(lib,"rb").read()
out=[]
for (a,n),(b,_) in zip(rows,rows[1:]):
  sz=b-a
  if sz<256 or b>tsize: continue
  buf=data[a:b]
  for dt in ["<f4","<i4","<i2","<u2","u1","<f8"]:
    k=np.dtype(dt).itemsize; x=np.frombuffer(buf[:len(buf)//k*k],dt).astype(np.float64)
    if len(x)<64 or not np.all(np.isfinite(x)): continue
    if dt in("<f4","<f8") and (np.abs(x).max()>1e6 or np.abs(x).max()<1e-6): continue
    v=x.var()
    if v<=0: continue
    sm=np.mean(np.diff(x)**2)/v  # small = smooth
    uniq=len(np.unique(x))/len(x)
    if sm<0.05 and uniq>0.3:
      out.append((sm,n,a,sz,dt,len(x)))
for o in sorted(out,key=lambda o:o[1]): print(f"{o[1]:40s} off={o[2]:#x} bytes={o[3]} {o[4]} n={o[5]} smooth={o[0]:.4f}")
