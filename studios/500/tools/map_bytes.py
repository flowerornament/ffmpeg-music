# map_bytes.py FILE RATE [chunk_seconds] [start_byte]
# Periodicity map of any file read as u8 at RATE: per chunk rms, fraction of zero bytes,
# fraction of printable text, and the 3 strongest spectral peaks (Hz). Periodic structures
# (instructions, pointer tables, structs) show up as RATE/size. Run: uv run --with numpy python map_bytes.py ...
import sys, numpy as np
f=sys.argv[1]; R=float(sys.argv[2]); cs=float(sys.argv[3]) if len(sys.argv)>3 else 2; st=int(sys.argv[4]) if len(sys.argv)>4 else 0
b=np.fromfile(f,dtype=np.uint8).astype(float)-128; N=int(R*cs)
for i in range(st,len(b)-N,N):
    s=b[i:i+N]; S=np.abs(np.fft.rfft(s*np.hanning(N)))**2; S[:20]=0
    fr=np.fft.rfftfreq(N,1/R); ks=np.argsort(S)[-3:][::-1]
    z=np.mean(s==-128); txt=np.mean((s+128>=32)&(s+128<127))
    print(f'{i:9d} {(i-st)/R:7.1f}s rms{20*np.log10(np.std(s)/128+1e-9):6.1f} zeros{z:4.2f} text{txt:4.2f} peaks '+' '.join(f'{fr[k]:.0f}' for k in ks))
