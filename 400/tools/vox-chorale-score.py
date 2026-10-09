rows=[l.split() for l in open('chorale.txt')]
P={'S':40,'A':40,'T':40,'B':80}; G={'S':0.8,'A':0.75,'T':0.8,'B':1.0}
PAN={'S':(0.62,0.38),'A':(0.38,0.62),'T':(0.56,0.44),'B':(0.5,0.5)}
lines=[];lab=[]
def sing(part,v,f,start,dur,g=None):
    D=int(round(f*P[part])); l,r=PAN[part]; g=G[part] if g is None else g; lab.append(f"v{len(lab)}")
    lines.append(f"$(sing ${v.upper()}{P[part]} {D} {int(start*1000)} {dur+0.25:.2f} {dur+0.05:.2f} {g} {l} {r})[{lab[-1]}];")
marks=[]
t=1.0; beat=1.15; marks.append(('I. soprano alone',t))
for name,v,ch,d,S,A,T,B in rows:
    if name!='S1': continue
    sing('S',v,float(S),t,int(d)*beat,1.0); t+=int(d)*beat
t+=1.5; beat=1.3
for sec in ('S1','S2','S3'):
    marks.append({'S1':'II. chorale','S2':'III. tenor melody','S3':'IV. full, to the cadence'}[sec],t) if False else marks.append(({'S1':'II. chorale','S2':'III. tenor takes the melody','S3':'IV. full choir, the climax and cadence'}[sec],t))
    rs=[r for r in rows if r[0]==sec]
    for i,(name,v,ch,d,S,A,T,B) in enumerate(rs):
        b=beat*(1.4 if sec=='S3' and i>=len(rs)-4 else 1.0); dur=int(d)*b
        if sec=='S2':
            sing('T',v,float(S)/2,t,dur,0.95); sing('A',v,float(A),t,dur,0.6); sing('B',v,float(B),t,dur,0.9)
        else:
            for part,f in zip('SATB',(S,A,T,B)): sing(part,v,float(f),t,dur)
        t+=dur
    t+=0.4 if sec!='S3' else 0
# coda: hold final chord, vowel morph (the last S3 chord is re-sung under e->a->o)
last=[r for r in rows if r[0]=='S3'][-1]
t-=int(last[3])*beat*1.4*0.5; marks.append(('V. the last chord, e -> a -> o',t))
for i,v in enumerate('eao'):
    for part,f in zip('SATB',last[4:]): sing(part,v,float(f),t+i*5.0,8.0)
print("\n".join(lines)); print("#LABELS "+"".join(f"[{x}]" for x in lab)); print(f"#N {len(lab)} END {t+18:.1f}")
for m,tt in marks: print(f"#MARK {m} {tt:.1f}")
