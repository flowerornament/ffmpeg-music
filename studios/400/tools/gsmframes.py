"""GSM 06.10 full-rate frame packer for composing with ffmpeg's gsm decoder (studio 400).

A frame = 33 bytes = 20 ms at 8 kHz (160 samples). Bit layout (RFC 3551, MSB first):
  magic 0xD (4) | LARc[8] (6,6,5,5,4,4,3,3) | 4 x [Nc lag 7 | bc gain 2 | Mc grid 2 | xmaxc 6 | 13 x 3-bit pulses]
Pulse codes: 0 large negative, 3/4 small -/+, 7 large positive (there is no zero).
Design the vocal tract at 8 kHz (designing at the declared rate saturates the lattice);
pitch = declared sample_rate / P where P = samples between glottal pulses (40 or 80).

usage:
  python3 gsmframes.py vowel e 40          -> base64 of 3 copies of an 'e' frame, pulse every 40
  python3 gsmframes.py overtone 7          -> frame whistling harmonic 7 (sygyt)
  python3 gsmframes.py formants 400,1200 300,80 [xmax] [P]
In ffmpeg: amovie='data\\:application/octet-stream;base64,B64':f=gsm:format_opts='sample_rate=R',
  asetpts=N/SR/TB,atrim=start_sample=320:end_sample=480,asetpts=N/SR/TB,aloop=-1:160,asetpts=N/SR/TB
"""
import sys, base64
import numpy as np
LARBITS = [6, 6, 5, 5, 4, 4, 3, 3]
A = [20, 20, 20, 20, 13.637, 15, 8.334, 8.824]
B = [0, 0, 4, -5, 0.184, -3.5, -0.666, -2.235]
MIC = [-32, -32, -16, -16, -8, -8, -4, -4]
MAC = [31, 31, 15, 15, 7, 7, 3, 3]
VOWELS = {'a': ([730, 1090, 2440, 3400], [90, 110, 170, 250]), 'i': ([270, 2290, 3010, 3500], [60, 90, 150, 200]),
          'u': ([300, 870, 2240, 3300], [60, 100, 150, 200]), 'e': ([530, 1840, 2480, 3400], [60, 100, 150, 200]),
          'o': ([570, 840, 2410, 3300], [70, 100, 150, 200])}

def pack(larc, subs):
    bits = [(0xD, 4)] + [(larc[i], LARBITS[i]) for i in range(8)]
    for (Nc, bc, Mc, xmaxc, xM) in subs:
        bits += [(Nc, 7), (bc, 2), (Mc, 2), (xmaxc, 6)] + [(x, 3) for x in xM]
    v = 0
    for val, b in bits:
        v = (v << b) | (int(val) & ((1 << b) - 1))
    return v.to_bytes(33, 'big')

def lar_from_refl(r):
    out = []
    for i, k in enumerate(r):
        a = abs(k)
        L = k if a < 0.675 else np.sign(k) * ((2 * a - 0.675) if a < 0.95 else (8 * a - 6.375))
        c = int(round(A[i] * L + B[i]))
        out.append(max(MIC[i], min(MAC[i], c)) - MIC[i])
    return out

def refl(F, BW, fs=8000):
    """formant list -> 8 reflection coefficients (step-down recursion), sign as ffmpeg expects"""
    a = np.array([1.0])
    for f, bw in zip(F, BW):
        if f > 0.42 * fs:
            continue
        r = np.exp(-np.pi * bw / fs); th = 2 * np.pi * f / fs
        a = np.convolve(a, [1, -2 * r * np.cos(th), r * r])
    a = np.concatenate([a, np.zeros(9)])[:9]; k = np.zeros(8); cur = a.copy()
    for m in range(8, 0, -1):
        k[m - 1] = np.clip(cur[m], -0.995, 0.995)
        cur = (cur[:m + 1] - k[m - 1] * cur[:m + 1][::-1]) / (1 - k[m - 1] ** 2)
    return list(k)

def frame(F, BW, xmax=14, P=40, copies=3):
    larc = lar_from_refl(refl(F, BW))
    on = [7] + [3, 4] * 6; off = [3, 4] * 6 + [3]
    subs = [(40, 0, 0, xmax if (j * 40) % P == 0 else 0, on if (j * 40) % P == 0 else off) for j in range(4)]
    return base64.b64encode(pack(larc, subs) * copies).decode()

if __name__ == '__main__':
    mode = sys.argv[1]
    if mode == 'vowel':
        print(frame(*VOWELS[sys.argv[2]], P=int(sys.argv[3]) if len(sys.argv) > 3 else 40))
    elif mode == 'overtone':
        k = int(sys.argv[2]); print(frame([400, 200 * k, 200 * k], [300, 20, 20], xmax=10))
    elif mode == 'formants':
        F = [float(x) for x in sys.argv[2].split(',')]; BW = [float(x) for x in sys.argv[3].split(',')]
        print(frame(F, BW, int(sys.argv[4]) if len(sys.argv) > 4 else 14, int(sys.argv[5]) if len(sys.argv) > 5 else 40))
