# rank 3-letter dictionary words as GSM "throats" (LAR3..8 when line = "# "+word+body+"\n")
import numpy as np, sys, re
from gsmline import dec
body=sys.argv[1] if len(sys.argv)>1 else 'dynamicnothingwhisperwaitin'
assert len(body)==27
ws=sorted({w.strip().lower() for w in open('/usr/share/dict/words') if re.fullmatch(r'[a-z]{3}',w.strip())})
text=''.join(('# '+w+body+'\n')*6 for w in ws)
x=dec(text); f=np.fft.rfftfreq(640,1/8000)
out=[]
for i,w in enumerate(ws):
    seg=x[(i*6+2)*160:(i*6+6)*160]; seg=seg-seg.mean()
    S=np.abs(np.fft.rfft(seg*np.hanning(640))); S[f<40]=0
    rms=20*np.log10(np.sqrt(np.mean(seg**2))+1e-9); cen=np.sum(f*S)/(np.sum(S)+1e-9)
    out.append((cen,rms,w))
ok=sorted([o for o in out if -28<o[1]<-6])
print(len(ok),'of',len(ws))
for o in ok[::max(1,len(ok)//30)]: print(f"{o[2]} cen={o[0]:5.0f} rms={o[1]:5.1f}")
