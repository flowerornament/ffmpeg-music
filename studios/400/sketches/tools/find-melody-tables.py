import sys, subprocess, numpy as np, re
lib=sys.argv[1]
nm=subprocess.run(["nm","-n",lib],capture_output=True,text=True).stdout.split("\n")
rows=[l.split() for l in nm if len(l.split())==3 and l.split()[1] in "sSdD"]
rows=[(int(a,16),n) for a,_,n in rows]
seg=subprocess.run(["otool","-l",lib],capture_output=True,text=True).stdout
tsize=int(re.search(r"segname __TEXT\n\s+vmaddr \S+\n\s+vmsize (\S+)",seg).group(1),16)
data=open(lib,"rb").read()
for (a,n),(b,_) in zip(rows,rows[1:]):
  sz=b-a
  if sz<48 or sz>2048 or b>tsize: continue
  x=np.frombuffer(data[a:b],np.uint8).astype(int)
  lo,hi=x.min(),x.max()
  ch=np.mean(np.diff(x)!=0)
  if hi-lo<=14 and hi-lo>=4 and ch>0.5 and len(np.unique(x))>=5:
    print(f"{n:36s} {a:#x} {sz:5d} range {lo}-{hi} change={ch:.2f} :: {' '.join(map(str,x[:40]))}")
