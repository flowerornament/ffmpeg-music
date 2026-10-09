# stanza.py: build GSM-aligned comment lines "# " + 30 chars, frame = chars[0:30]+"\n# "
# usage: stanza.py THROATS(5-letter words, comma sep) PITCH(4/line letters) DYN(4/line letters) LYRIC(17/line)
import sys
def line(throat, p, d, lyr):
    assert len(throat)==5 and len(p)==4 and len(d)==4 and len(lyr)==17, (throat,p,d,lyr)
    s = throat + p[0]+d[0] + lyr[0:5] + p[1]+d[1] + lyr[5:10] + p[2]+d[2] + lyr[10:15] + p[3]+d[3] + lyr[15:17]
    assert len(s)==30
    return '# '+s
if __name__=='__main__':
    th=sys.argv[1].split(','); P=sys.argv[2]; D=sys.argv[3]; Ly=sys.argv[4]
    for i,t in enumerate(th):
        print(line(t, P[4*i:4*i+4], D[4*i:4*i+4], Ly[17*i:17*i+17]))
