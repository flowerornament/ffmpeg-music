# gsmverse.py: build GSM-frame lines ("# " + 3-letter throat + four 7-letter words, the last cut to 6) whose
# subframe loudnesses follow an envelope. Loudness lives in the 2nd letter of each word (a=ppp .. z=fff, ' '=rest).
# Words come from /usr/share/dict/words, chosen (seeded) by their second letter.
import re, random, sys
random.seed(int(sys.argv[1]) if len(sys.argv)>1 else 3)
W7=[w.strip().lower() for w in open('/usr/share/dict/words') if re.fullmatch(r'[a-z]{7}',w.strip())]
by2={}
for w in W7: by2.setdefault(w[1],[]).append(w)
def word(level):        # level 0..26 (0 = rest)
    if level<=0: return '  '+random.choice(['river','sleep','night','still','quiet','waits'])
    c='abcdefghijklmnopqrstuvwxyz'[min(25,level-1)]
    return random.choice(by2[c])
def line(throat, levels):
    ws=[word(l) for l in levels]
    s='# '+throat+''.join(ws)
    return s[:32]
def syllable(throat, n, peak):
    # n lines, attack-sustain-decay envelope over 4n subframes
    L=[]; tot=4*n
    for i in range(n):
        lv=[]
        for j in range(4):
            k=i*4+j
            a=min(1,(k+1)/3)          # 3-subframe attack
            d=max(0,1-(k/tot)**1.5)   # decay
            lv.append(int(round(peak*a*d)))
        L.append(line(throat,lv))
    return L
if __name__=='__main__':
    spec=sys.argv[2]   # e.g. "hah:6:24 bib:4:20 -:2 pal:8:22"
    out=[]
    for tok in spec.split():
        if tok.startswith('-'): out+=[line(random.choice(['bib','hah']),[0,0,0,0]) for _ in range(int(tok.split(':')[1]))]
        else:
            t,n,p=tok.split(':'); out+=syllable(t,int(n),int(p))
    print('\n'.join(out))
