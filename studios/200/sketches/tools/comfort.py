# helper: print literal G.723.1 comfort-noise voice texts. word frames: SID (4 bytes) then 'o' erasures (1 byte, 30 ms each at 8 kHz)
# voice spec: (asetrate, [(t_start_seconds, word), ...], t_end)
import sys
def voice(sr, events, tend):
    spo = 240.0/sr   # seconds per frame after asetrate
    s=''; frames=0
    for i,(t0,w) in enumerate(events):
        target=int(round(t0/spo))
        if frames < target: s+='o'*(target-frames); frames=target   # leading rest (before first SID) or sustain
        s+=w; frames+=1
    s+='o'*max(0,int(round(tend/spo))-frames)
    return s
if __name__=='__main__':
    import json
    for sr,ev,te in json.loads(sys.stdin.read()):
        print(sr, len(voice(sr,ev,te)), voice(sr,ev,te))
