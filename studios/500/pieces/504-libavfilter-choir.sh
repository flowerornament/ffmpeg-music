#!/bin/sh
# 504 — libavfilter, sung
# The last 1.4 MB of the library this piece runs on (libavfilter.12.dylib — the code of
# anlms itself is in there) read as unsigned bytes at 14080 Hz. You never hear the bytes.
# You hear a choir of five adaptive filters (anlms, out_mode=e: the estimate) whose only
# inputs are band-limited impulse-train drones. Each can answer the bytes only with its
# own drone's harmonics, so the binary is sung in the overtones of an A-major chord.
# Why it is in tune: struct sizes are powers of two. At 14080 Hz, ARM64 instructions
# (always 4 bytes) ring at 3520 Hz = A7, 8-byte pointer tables at 1760 = A6, 64-byte
# structs at 220 = A3. The read rate is the tuning fork; the file supplies the form:
#   0'00 the end of the machine code (A7 shimmer)   0'04 strings: the filters' own help
#   texts (slow, low, almost vowels)   0'22 mixed data   0'34 20-byte records (~700 Hz,
#   answered by harmonics 12-13 of 55)   0'44 forty seconds of pointer tables (A6, sparse,
#   75% zeros)   1'24 more data   1'36 symbol names, then the end of the file.
# The students' harmonic ceilings are a voicing: only the highest can reach the A7 of the
# instruction stream; the low ones translate it into what they can sing.
#   A0 27.5 Hz (20 harmonics)  A1 55 (40)  C#2 68.75 (30)  E2 82.5 (26)  A3 220 (36)
L=${FFMPEG_MUSIC_LIB:-/nix/store/w7r73zzbx5r5igv9vafakpsvi6qhi0ck-ffmpeg-9.0.1-lib}/lib/libavfilter.12.1.101.dylib
BLIT='st(1,sin(PI*ld(0)));if(lt(abs(ld(1)),1e-6),1,(sin((2*K+1)*PI*ld(0))/ld(1)-1)/(2*K))*0.5'
D(){ echo "st(0,mod(ld(0)+$1/48000,1));$(echo "$BLIT" | sed "s/K/$2/g")"; }
ffmpeg -hide_banner -y -f u8 -ar 14080 -ac 1 -i "subfile,,start,3100000,end,4540000,,:$L" -filter_complex "
[0:a]aresample=48000,highpass=f=25,volume=0.5,afade=t=in:d=0.5,asplit=5[d0][d1][d2][d3][d4];
aevalsrc=s=48000:d=103:exprs='$(D 27.5 20)'[x0];
aevalsrc=s=48000:d=103:exprs='$(D 55 40)'[x1];
aevalsrc=s=48000:d=103:exprs='$(D 68.75 30)'[x2];
aevalsrc=s=48000:d=103:exprs='$(D 82.5 26)'[x3];
aevalsrc=s=48000:d=103:exprs='$(D 220 36)'[x4];
[x0][d0]anlms=order=1800:mu=0.004:out_mode=e,lowpass=f=400,pan=stereo|c0=c0|c1=c0[s0];
[x1][d1]anlms=order=900:mu=0.002:out_mode=e,pan=stereo|c0=c0|c1=0.45*c0[s1];
[x2][d2]anlms=order=720:mu=0.002:out_mode=e,pan=stereo|c0=0.75*c0|c1=0.75*c0,adecorrelate=stages=8:seed=3[s2];
[x3][d3]anlms=order=600:mu=0.002:out_mode=e,pan=stereo|c0=0.45*c0|c1=c0[s3];
[x4][d4]anlms=order=240:mu=0.002:out_mode=e,pan=stereo|c0=c0|c1=c0,adecorrelate=stages=12:seed=7[s4];
[s0][s1][s2][s3][s4]amix=inputs=5:weights=3.5 1 1 1 0.35:normalize=0,asplit[dry][w0];
aevalsrc=s=8000:d=3:exprs='(random(0)*2-1)*exp(-t*2.5)|(random(1)*2-1)*exp(-t*2.5)',aresample=48000[ir];
[w0][ir]afir=irnorm=2:irgain=0.4[wet];
[dry][wet]amix=inputs=2:weights=1 0.5:normalize=0,volume=1.5,
acompressor=threshold=0.4:ratio=2:attack=20:release=300,alimiter=level=0:limit=0.8,afade=t=out:st=97:d=6" "$@"
