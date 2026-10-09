import sys, numpy as np
R={'A':1,'B':9/8,'C':6/5,'D':4/3,'E':3/2,'F':8/5,'G':9/5,'G#':15/8}
CH={'i':['A','C','E'],'iv':['D','F','A'],'V':['E','G#','B'],'VI':['F','A','C'],'VII':['G','B','D'],'III':['C','E','G']}
def sop(pc,octv): return 440*R[pc]*2**(octv-4) if pc in('A','B','C','D','E','F','G','G#') else 0
# (vowel, chord, beats, soprano pc, soprano octave(A4=4 base, pitch classes above A count as same octave))
S1=[('e','i',1,'E',4),('e','i',1,'E',4),('e','VI',2,'F',4),('i','III',1,'E',4),('a','iv',1,'D',4),
    ('u','VI',1,'C',4),('i','VII',1,'D',4),('e','III',1,'E',4),('a','iv',2,'F',4),
    ('e','i',1,'E',4),('i','VII',1,'D',4),('a','V',2,'G#',3),('o','i',1,'A',4),('e','V',1,'B',4),('e','i',3,'A',4)]
S2=[('i','VI',1,'C',4),('a','VII',1,'D',4),('i','i',2,'E',4),('a','III',1,'E',4),('a','iv',2,'F',4),
    ('a','i',1,'E',4),('i','VII',1,'D',4),('e','VI',1,'C',4),('i','V',1,'B',4),('o','VI',1,'C',4),('i','iv',1,'D',4),('u','V',3,'E',4)]
S3=[('a','i',1,'E',4),('a','VI',1,'F',4),('o','VII',2,'G',4),('e','iv',1,'A',5),('i','III',1,'G',4),('u','VI',1,'F',4),('a','i',1,'E',4),
    ('e','iv',2,'A',5),('o','V',1,'G#',4),('a','i',1,'A',5),('o','i',1,'E',4),('o','iv',1,'D',4),('u','VI',1,'C',4),('o','V',1,'B',4),('a','i',4,'A',4)]
def freqs(pc,lo,hi): return [110*R[pc]*2**o for o in range(-3,5) if lo<=110*R[pc]*2**o<=hi]
rng={'A':(220,600),'T':(140,380),'B':(70,175)}
def harmonize(rows,prev):
    out=[]
    for v,ch,d,spc,so in rows:
        t=CH[ch]; s=440*R[spc]*2**(so-4)
        c={'S':s}
        c['B']=min(freqs(t[0],*rng['B']),key=lambda f:abs(np.log(f/prev['B'])))
        used=[spc,t[0]]
        for part in 'AT':
            cands=[(f,pc) for pc in t for f in freqs(pc,*rng[part]) if f<c['S']*0.99 and (part=='A' or f<c['A']*0.99)]
            best=min(cands,key=lambda x:abs(np.log(x[0]/prev[part]))+(0.12 if x[1] in used else 0))
            c[part]=best[0]; used.append(best[1])
        prev=c; out.append((v,ch,d,c))
    return out,prev
prev={'A':330,'T':264,'B':110}
allrows=[]
for name,S in (('S1',S1),('S2',S2),('S3',S3)):
    h,prev=harmonize(S,prev); allrows.append((name,h))
    for v,ch,d,c in h: print(name,v,ch,d,' '.join(f"{c[p]:.4f}" for p in 'SATB'))
