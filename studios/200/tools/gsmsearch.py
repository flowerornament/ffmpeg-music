import random, subprocess, numpy as np
from gsmline import dec
random.seed(1)
A='abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ.,;:!?'
cands=[''.join(random.choice(A) for _ in range(5)) for _ in range(300)]
rest=' '*27
text=''.join((c+rest+'\n')*6 for c in cands)
x=dec(text)
res=[]
for i,c in enumerate(cands):
    seg=x[(i*6+4)*160:(i*6+5)*160]
    res.append((20*np.log10(np.sqrt(np.mean(seg**2))+1e-9),c))
res.sort()
for r in res[:15]: print(f"{r[0]:6.1f} {r[1]!r}")
print('...'); 
for r in res[-5:]: print(f"{r[0]:6.1f} {r[1]!r}")
