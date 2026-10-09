import sys, numpy as np
from gsmline import dec
# stanzarms.py file start end : decode bytes [start,end) looped 3x, print per-subframe dB of the last pass
d=open(sys.argv[1],'rb').read()[int(sys.argv[2]):int(sys.argv[3])]
x=dec((d*3).decode('latin1'))
n=len(d)//33; x=x[-n*160:]
for i in range(n):
    print(' '.join(f"{20*np.log10(np.sqrt(np.mean(x[i*160+j*40:i*160+j*40+40]**2))+1e-9):6.1f}" for j in range(4)), '|', d[i*33:i*33+30].decode('latin1'))
